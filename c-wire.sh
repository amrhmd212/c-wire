# Fonction pour afficher l'aide
afficher_aide() {
    echo "Utilisation : $0 <fichier_csv> <type_station> <type_consommateur> [<id_centrale>] [-h]"
    echo ""
    echo "Options :"
    echo "  <fichier_csv>         Chemin du fichier CSV contenant les données (obligatoire)"
    echo "  <type_station>        Type de station à traiter : hvb, hva, lv (obligatoire)"
    echo "  <type_consommateur>   Type de consommateur : comp, indiv, all (obligatoire)"
    echo "  <id_centrale>         Identifiant de la centrale (optionnel)"
    echo "  -h                    Affiche cette aide et ignore les autres options"
    exit 0
}

# Vérifier si l'option -h est présente
for arg in "$@"; do
    if [ "$arg" == "-h" ]; then
        afficher_aide
    fi
done

# Vérification des arguments obligatoires
if [ "$#" -lt 3 ]; then
    echo "Erreur : Nombre insuffisant d'arguments."
    afficher_aide
fi

fichier_csv="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="$4"

# Vérification des types de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Type de station invalide. Utilisez 'hvb', 'hva' ou 'lv'."
    afficher_aide
fi

# Vérification des types de consommateur
if [[ "$type_station" == "hvb" && "$type_consommateur" != "comp" ]]; then
    echo "Erreur : Pour 'hvb', seul 'comp' est autorisé."
    afficher_aide
fi
if [[ "$type_station" == "hva" && "$type_consommateur" != "comp" ]]; then
    echo "Erreur : Pour 'hva', seul 'comp' est autorisé."
    afficher_aide
fi
if [[ "$type_station" == "lv" && "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide pour 'lv'."
    afficher_aide
fi

# Vérification de la présence du fichier CSV
if [ ! -f "$fichier_csv" ]; then
    echo "Erreur : Le fichier '$fichier_csv' n'existe pas."
    exit 1
fi

# Copier le fichier CSV dans le dossier 'input'
if [ ! -d "input" ]; then
    mkdir input
fi
cp "$fichier_csv" input/


# Vérifier si le dossier graphs existe, sinon le créer
if [ ! -d "graphs" ]; then
    mkdir graphs
fi

# Compiler le programme C
echo "Compilation du programme C..."
gcc main.c -o main
if [ $? -ne 0 ]; then
    echo "Erreur : La compilation a échoué."
    exit 2
fi

# Filtrage des données en fonction des options
echo "Filtrage des données..."

if [ ! -s "$fichier_filtre" ]; then
    echo "Erreur : Aucun résultat correspondant aux critères."
    exit 3
fi

# Lancer le programme C pour le calcul
echo "Lancement du programme C..."
temps_debut=$(date +%s.%N)
./main "$fichier_filtre" "$type_station" "$type_consommateur"
temps_fin=$(date +%s.%N)

# Calcul de la durée du traitement
duree=$(echo "$temps_fin - $temps_debut" | bc)
echo "Durée du traitement : $duree secondes."

# Vérifier la sortie et générer un graphique si nécessaire
if [ "$type_station" == "lv" ] && [ "$type_consommateur" == "all" ]; then
    echo "Création des graphiques pour les postes LV les plus et les moins chargés..."
    gnuplot -e "set terminal png; set output 'graphs/lv_all_minmax.png'; plot 'tmp/filtre.csv' using 1:3 with bars"
fi

# Ajout de graphiques pour hvb et hva
if [ "$type_station" == "hvb" ] && [ "$type_consommateur" == "comp"]; then
    awk -F';' '$2 != "-" && $4 == "-" && $7 == "-"  $2 != "-" && $3 == "-" && $4 == "-" && $5 == "-" && $6 == "-"' "cwire.dat"| cut -d';' -f2,5,7,8 | tr '-' '0'| ./main
    echo "Création des graphiques pour les stations HVB..."
    gnuplot -e "set terminal png; set output 'graphs/hvb_load.png'; plot 'tmp/filtre.csv' using 1:3 with linespoints"
fi
if [ "$type_station" == "hva" ] && [ "$type_consommateur" == "comp"]; then
    awk -F';' '$3 != "-" && $5 != "-" && $7 == "-"  $2 != "-" && $3 != "-" && $4 == "-" ' "cwire.dat"| cut -d';' -f3,5,7,8 | tr '-' '0'| ./main
    echo "Création des graphiques pour les stations HVA..."
    gnuplot -e "set terminal png; set output 'graphs/hva_load.png'; plot 'tmp/filtre.csv' using 1:3 with linespoints"
fi

if [ "$type_station" == "lv" ] && [ "$type_consommateur" == "indiv"]; then
    awk -F';' '$4 != "-" && $6 != "-" && $7 == "-"$3 != "-" && $4 != "-" && $8 == "-"' "cwire.dat" | cut -d';' -f4,6,7,8 | tr '-' '0'| ./main
    echo "Création des graphiques pour les stations HVA..."
    gnuplot -e "set terminal png; set output 'graphs/hva_load.png'; plot 'tmp/filtre.csv' using 1:3 with linespoints"
fi

# Fonction clean pour nettoyer les fichiers générés
clean() {
    echo "Nettoyage des fichiers temporaires et graphiques..."
    rm -rf tmp/* graphs/* input/*
    echo "Nettoyage terminé."
}

# Traitement terminé
echo "Traitement terminé."
