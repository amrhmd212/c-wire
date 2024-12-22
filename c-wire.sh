#!/bin/bash


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

# Début du chronomètre
start_time=$(date +%s.%N)


# Création du dossier codeC s'il n'existe pas
mkdir -p codeC

# Déplacement des fichiers .c et .h dans le dossier codeC (s'ils ne sont pas déjà déplacés)
if compgen -G ".c" > /dev/null || compgen -G ".h" > /dev/null; then # Vérification si les fichiers .c et .h existent
    mv *.c *.h codeC/ # Déplacement des fichiers .c et .h dans le dossier codeC
    echo "Les fichiers .c et .h ont été déplacés dans le dossier codeC." # Affichage d'un message de confirmation
fi


# Vérification des fichiers source dans le dossier codeC
if [ ! -f "codeC/main.c" ]; then # Vérification si le fichier main.c existe dans le dossier codeC
    echo "Erreur : Fichier 'main.c' introuvable dans le dossier 'codeC'." # Affichage d'un message d'erreur
    exit 1 # Sortie du script avec code d'erreur 1
fi
rm -rf tests/* #suppression des fichiers dans le dossier tests si ils existent 
# Suppression des fichiers dans le dossier tests s'ils existent
make clean -C codeC # Nettoyage du dossier codeC
make -C codeC # Création des fichiers .o et .a dans le dossier codeC
if [ $? -ne 0 ]; then # Vérification si la création des fichiers .o et .a a réussi
    echo "Erreur : Échec de la compilation du programme C." # Affichage d'un message d'erreur
    exit 1 # Sortie du script avec code d'erreur 1
fi


# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then # Verification si le nombre d'arguments est inférieur à 3
    echo "Erreur : Nombre insuffisant d'arguments." # Affichage d'un message d'erreur car pas assez d'arguments
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    afficher_aide # Affichage de l'aide
fi

# Arguments
fichier_csv="$1" # Fichier d'entrée CSV 
type_station="$2" # Type de station à traiter
type_consommateur="$3" # Type de consommateur à traiter
id_centrale="$4" # Identifiant de la centrale

# Création du dossier input s'il n'existe pas
mkdir -p input

# Gestion dynamique du chemin d'entrée pour le fichier CSV
if [ -f "input/$fichier_csv" ]; then # Vérification si le fichier CSV existe dans le dossier input
    input_file="input/$fichier_csv" # Chemin complet du fichier CSV dans le dossier input
    echo "Le fichier '$fichier_csv' a été trouvé dans le dossier 'input/'." # Affichage d'un message de confirmation pour indiquer que le fichier d'entrée csv est trouvé
elif [ -f "$fichier_csv" ]; then # Vérification si le fichier CSV existe dans le répertoire courant
    mv "$fichier_csv" input/ # Déplacement du fichier d'entree CSv  dans le dossier input
    input_file="input/$fichier_csv" # Chemin complet du fichier d'entree CSV  dans le dossier input
    echo "Le fichier '$fichier_csv' a été déplacé dans le dossier 'input/'." # Affichage d'un message de confirmation pour le fichier d'entrée csv déplacé
else # Si le fichier CSV n'existe pas dans le dossier input ou dans le répertoire courant
    echo "Erreur : Le fichier '$fichier_csv' n'existe ni dans 'input/' ni dans le répertoire courant." # Affichage d'un message d'erreur car le fichier d'entrée csv n'existe pas
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    exit 1 # Sortie du script avec code d'erreur 1
fi



# Vérification des types de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then # Verification si le type de station est hvb, hva ou lv
    echo "Erreur : Type de station invalide. Utilisez 'hvb', 'hva', ou 'lv'." # Affichage d'un message d'erreur car type de station invalide
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    afficher_aide # Affichage de l'aide
fi

# Vérification des types de consommateur
if [[ "$type_station" == "hvb" && "$type_consommateur" != "comp" ]]; then # Verification si le type de consommateur est comp pour la station hvb
    echo "Erreur : Pour 'hvb', seul 'comp' est autorisé." # Affichage d'un message d'erreur car type de consommateur invalide pour la station
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    afficher_aide # Affichage de l'aide
fi

if [[ "$type_station" == "hva" && "$type_consommateur" != "comp" ]]; then # Verification si le type de consommateur est comp pour la station hva
    echo "Erreur : Pour 'hva', seul 'comp' est autorisé." # Affichage d'un message d'erreur car type de consommateur invalide pour la station
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    afficher_aide # Affichage de l'aide
fi

if [[ "$type_station" == "lv" && "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then # Verification si le type de consommateur est comp, indiv ou all pour la station lv
    echo "Erreur : Type de consommateur invalide pour 'lv'." # Affichage d'un message d'erreur car type de consommateur invalide pour la station
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    afficher_aide # Affichage de l'aide
fi


# Vérification du fichier d'entrée dans le dossier 'input'
input_file="input/$1" # Chemin complet du fichier d'entrée dans le dossier input
if [ ! -f "$input_file" ]; then # Vérification si le fichier d'entrée existe dans le dossier input
    echo "Erreur : Le fichier '$input_file' n'existe pas." # Affichage d'un message d'erreur car fichier d'entrée introuvable
    exit 1 # Sortie du script avec code d'erreur 1
fi

# Création des dossiers nécessaires
mkdir -p tmp graphs tests


# Gestion de l'identifiant de centrale
filtre_centrale="" # Initialisation de la variable filtre_centrale
if [ -n "$id_centrale" ]; then # Verification si l'identifiant de la centrale est fourni
    if [ "$id_centrale" -ge 1 ] && [ "$id_centrale" -le 5 ]; then # Verification si l'identifiant de centrale est compris entre 1 et 5
        filtre_centrale="\$1 == \"$id_centrale\" &&" # Construction de la condition de filtrage pour l'identifiant de centrale
    else # Si l'identifiant de centrale n'est pas compris entre 1 et 5
        echo "Erreur : L'identifiant de la centrale doit être compris entre 1 et 5." # Affichage d'un message d'erreur car identifiant de centrale invalide
        exit 1 # Sortie du script avec code d'erreur 1
    fi
fi



# Traitement des cas selon les types de station et de consommateur
if [[ "$type_station" == "hvb" && "$type_consommateur" == "comp" ]]; then # Traitement pour la station hvb et le consommateur comp
    echo "Station HV-B;Capacité;Consommation (entreprises)" > tmp/temptete.dat # Ecriture de l'en-tête dans le fichier tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni

        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$2 != \"-\" && \$4 == \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 == \"-\" && \$4 == \"-\" && \$5 == \"-\" && \$6 == \"-\"" | \
        cut -d';' -f2,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv 
    else # Si l'identifiant de centrale n'est pas fourni
        grep -E "^$id_centrale;" "$input_file" | \
        awk -F';' "$filtre_centrale \$2 != \"-\" && \$4 == \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 == \"-\" && \$4 == \"-\" && \$5 == \"-\" && \$6 == \"-\"" | \
        cut -d';' -f2,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    fi
    sort -t';' -k2,2n tests/resultat.csv -o tests/resultat.csv # Tri du fichier tests/resultat.csv par ordre décroissant de la colonne 2 (capacité)
    mv tests/resultat.csv "tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Déplacement du fichier tests/resultat.csv dans le dossier tests avec le nom correspondant au type de station et au type de consommateur et à l'identifiant de la centrale
    echo "Résultats enregistrés dans tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Affichage d'un message de confirmation de l'enregistrement des résultats dans le dossier tests

elif [[ "$type_station" == "hva" && "$type_consommateur" == "comp" ]]; then # Traitement pour la station hva et le consommateur comp
    echo "Station HV-A;Capacité;Consommation (entreprises)" > tmp/temptete.dat # Ecriture de l'en-tête dans le fichier tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni
        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$3 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 != \"-\" && \$4 == \"-\"" | \
        cut -d';' -f3,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    else # Si l'identifiant de la centrale n'est pas fourni
        grep -E "^$id_centrale;" "$input_file" | \
        awk -F';' "$filtre_centrale \$3 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 != \"-\" && \$4 == \"-\"" | \
        cut -d';' -f3,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    fi
    sort -t';' -k2,2n tests/resultat.csv -o tests/resultat.csv # Tri du fichier tests/resultat.csv par ordre décroissant de la colonne 2 (capacité)
    mv tests/resultat.csv "tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Déplacement du fichier tests/resultat.csv dans le dossier tests avec le nom correspondant au type de station et au type de consommateur et à l'identifiant de centrale
    echo "Résultats enregistrés dans tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Affichage d'un message de confirmation de l'enregistrement des résultats dans le dossier tests

elif [[ "$type_station" == "lv" && "$type_consommateur" == "comp" ]]; then # Traitement pour la station lv et le consommateur comp
    echo "Station LV;Capacité;Consommation (entreprises)" > tmp/temptete.dat # Ecriture de l'en-tête dans le fichier tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni
        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    else # Si l'identifiant de la centrale n'est pas fourni
        grep -E "^$id_centrale;" "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    fi
    sort -t';' -k2,2n tests/resultat.csv -o tests/resultat.csv # Tri du fichier tests/resultat.csv par ordre décroissant de la colonne 2 (capacité)
    mv tests/resultat.csv "tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Déplacement du fichier tests/resultat.csv dans le dossier tests avec le nom correspondant au type de station et au type de consommateur et à l'identifiant de la centrale
    echo "Résultats enregistrés dans tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Affichage d'un message de confirmation de l'enregistrement des résultats dans le dossiser tests


elif [[ "$type_station" == "lv" && "$type_consommateur" == "indiv" ]]; then # Traitement pour la station lv et le consommateur indiv
    echo "Station LV;Capacité;Consommation (particuliers)" > tmp/temptete.dat # Ecriture de l'en-tête dans le fichier tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni
        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,6,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv
    else # Si l'identifiant de la centrale n'est pas fourni
        grep -E "^$id_centrale;" "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,6,7,8 | tr '-' '0' | ./codeC/avl_program > tests/resultat.csv 
    fi
    sort -t';' -k2,2n tests/resultat.csv -o tests/resultat.csv # Tri du fichier tests/resultat.csv par ordre décroissant de la colonne 2
    mv tests/resultat.csv "tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Déplacement du fichier tests/resultat.csv dans le dossier tests avec le nom correspondant au type de station et au type de consommateur et à l'identifiant de la centrale
    echo "Résultats enregistrés dans tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Affichage d'un message de confirmation de l'enregistrement des résultats dans le dossier tests

elif [[ "$type_station" == "lv" && "$type_consommateur" == "all" ]]; then # Traitement pour la station lv et le consommateur all
    echo "Station LV;Capacité;Consommation (Tous)" > tmp/temptete.dat # Ecriture de l'en-tête dans le fichier tmp/temptete.dat
    # Filtre pour "comp" (entreprises)
    comp_file="tmp/comp_data.csv" # initialisation de la variable comp_file
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni
        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' > "$comp_file"
    else # Si l'identifiant de la centrale n'est pas fourni
        grep -E "^$id_centrale;" "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' > "$comp_file"
    fi
    # Vérification du fichier comp_data.csv
    if [ ! -s "$comp_file" ]; then # Vérification si le fichier comp_data.csv est vide
        echo "Erreur : Le fichier $comp_file est vide ou n'a pas été créé. Vérifiez les filtres." # Affichage d'un message d'erreur car fichier comp_data.csv vide
        exit 1 # Sortie du script avec code d'erreur 1
    fi

    # Filtre pour "indiv" (particuliers)
    indiv_file="tmp/indiv_data.csv" # mise en place de la variable indiv_file
    if [[ -z "$id_centrale" ]]; then # Verification si l'identifiant de la centrale est fourni
        cat "$input_file" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,6,7,8 | tr '-' '0' > "$indiv_file"
    else # Si l'identifiant de la centrale n'est pas fourni
    grep -E "^$id_centrale;" "$input_file" | \
    awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
    cut -d';' -f4,6,7,8 | tr '-' '0' > "$indiv_file"
    fi

    # Vérification du fichier indiv_data.csv
    if [ ! -s "$indiv_file" ]; then # Vérification si le fichier indiv_data.csv est vide
        echo "Erreur : Le fichier $indiv_file est vide ou n'a pas été créé. Vérifiez les filtres." # Affichage d'un message d'erreur car fichier indiv_data.csv vide
        exit 1 # Sortie du script avec code d'erreur 1
    fi

    # Combinaison des deux fichiers
    combined_file="tmp/all_data.csv" # mise en place de la variable combined_file
    cat "$comp_file" "$indiv_file" > "$combined_file" # Combinaison des deux fichiers en utilisant la commande cat
    if [ ! -s "$combined_file" ]; then # Vérification si le fichier combined_file est vide
        echo "Erreur : Le fichier combiné $combined_file est vide." # Affichage d'un message d'erreur car fichier combined_file vide
        exit 1 # Sortie du script avec code d'erreur 1
    fi

    # Exécution du programme C
    ./codeC/avl_program < "$combined_file" > tests/resultat.csv # Exécution du programme C avec le fichier combined_file en tant que flux d'entrée et le
    if [ ! -s tests/resultat.csv ]; then # Vérification si le fichier resultat.csv est vide
        echo "Erreur : Le fichier tests/lv_all_resultat.csv n'a pas été généré." # Affichage d'un message d'erreur car fichier resultat.csv vide
        exit 1 # Sortie du script avec code d'erreur 1
    fi

    # Renommer le fichier de sortie
    sort -t';' -k2,2n tests/resultat.csv -o tests/resultat.csv # Tri du fichier tests/resultat.csv par ordre décroissant de la colonne 2
    mv tests/resultat.csv "tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Déplacement du fichier tests/resultat.csv dans le dossier tests avec le nom correspondant au type de station et au type de consommateur et à l'identifiant de centrale
    echo "Résultats enregistrés dans tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # Affichage d'un message de confirmation de l'enregistrement des résultats dans le dossier tests

    # Extraire les top et bottom 10
    extract_top_10() {
        local input_csv="tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # mise en place de la variable locale input_csv
        local output_csv="tests/lv_all_min_max.csv" # mise en place de la variable locale output_csv
        if [ ! -f "$input_csv" ]; then # Vérification si le fichier input_csv existe
            echo "Erreur : Le fichier '$input_csv' n'existe pas." # Affichage d'un message d'erreur car fichier input_csv inexistant
            exit 1 # Sortie du script avec code d'erreur 1
        fi
        echo "Station LV;Capacité;Consommation(tous)" > "$output_csv" # Ecriture de l'en-tête dans le fichier output_csv
        awk -F';' 'NR > 1 {
            diff = $3 - $2; 
            print $1 ";" $2 ";" $3 ";" diff
        }' "$input_csv" | sort -t';' -k4,4nr | head -n 10 | cut -d';' -f1-3 >> "$output_csv" # Extraction des 10 premières lignes triées par ordre décroissant de la colonne 4

        echo "Les 10 stations avec les plus grandes différences (consommation-capacité) ont été ajoutées à $output_csv." # Affichage d'un message de confirmation de l'ajout des 10 stations avec les plus grandes diffé
    }

    extract_bottom_10() {
        local input_csv="tests/${type_station}_${type_consommateur}_${id_centrale}_resultat.csv" # mise en place de la variable locale input_csv
        local output_csv="tests/lv_all_min_max.csv" # mise en place de la variable locale output_csv

        if [ ! -f "$input_csv" ]; then # Vérification si le fichier input_csv existe
            echo "Erreur : Le fichier '$input_csv' n'existe pas." # Affichage d'un message d'erreur car fichier input_csv inexistant
            exit 1 # Sortie du script avec code d'erreur 1
        fi

        awk -F';' 'NR > 1 && $3 > $2 {
            diff = $3 - $2;
            print $1 ";" $2 ";" $3 ";" diff
        }' "$input_csv" | sort -t';' -k4,4nr | tail -n 10 | cut -d';' -f1-3 >> "$output_csv" # Extraction des 10 dernières lignes triées par ordre décroissant de la colonne

        echo "Les 10 stations avec les plus petites différences (consommation-capacité) ont été ajoutées à $output_csv." # Affichage d'un message de confirmation de l'ajout des 10 stations avec les plus petites diffé
    }

    generate_graph() { # fonction pour la génération du graphique
        local data_file="tests/lv_all_min_max.csv" # mise en place de la variable locale data_file
        local plot_file="graphs/graph.png"  # mise en place de la variable locale plot_file

        if ! command -v gnuplot &> /dev/null; then # Vérification si le programme gnuplot est installé
            echo "Erreur : Gnuplot n'est pas installé." # Affichage d'un message d'erreur car gnuplot non installé
            exit 1 # Sortie du script avec code d'erreur 1
        fi

        # Générer un graphique avec Gnuplot
        gnuplot <<-EOF
            set terminal png size 1200,800 # Définition du format de l'image
            set output '${plot_file}' # Définition du nom du fichier de sortie
            set title "Postes LV les plus et les moins chargés" # Définition du titre du graphique
            set xlabel "Postes LV" # Définition de l'axe des abscisses
            set ylabel "Consommation (kWh)" # Définition de l'axe des ordonnées
            set boxwidth 0.8 # Définition de la largeur des boîtes
            set style fill solid # Définition du style de remplissage des boîtes
            set grid ytics # Définition des graduations sur l'axe des ordonnées
            set datafile separator ';' # Définition du séparateur des données

            # Définir les couleurs : rouge pour consommation > capacité, vert sinon
            set style line 1 lc rgb "red"
            set style line 2 lc rgb "green"

            # Légende explicite
            set key outside top center # Définition de la position de la clé
            set style data histogram # Définition du style des données
            set style histogram cluster gap 1 # Définition de la disposition des clusters
            set xtic rotate by -45 scale 0 # Définition de l'orientation des étiquettes de l'axe des abscisses

            # Tracé des données
            plot \
            '${data_file}' using 2:xtic(1) title "Capacité" with histograms ls 2, \
            '' using 3 title "Consommation" with histograms ls 1
EOF

            echo "Le graphique a été généré dans le fichier '${plot_file}'." # Affichage d'un message de confirmation de la génération du graphique
    }

# Exécuter les fonctions pour lv et all
    extract_top_10 # Extraction des top 10
    extract_bottom_10 # Extraction des bottom 10
    generate_graph # Génération du graphique
else
    echo "Erreur : Combinaison d'arguments invalide." # Affichage d'un message d'erreur car combinaison d'arguments invalide
    echo "Durée totale de traitement : 0.0s" # Affichage de la durée totale de traitement
    exit 1 # Sortie du script avec code d'erreur 1
fi

# Fin du chronomètre et affichage de la durée
end_time=$(date +%s.%N) # Récupération de l'heure de fin du chronomètre
elapsed_time=$(awk "BEGIN {print $end_time - $start_time}") # Calcul de la durée écoulée en secondes
echo "Durée totale de traitement : ${elapsed_time}s" # Affichage de la durée totale de traitement

# Vérifiez si le fichier existe dans le répertoire courant avant de le déplacer
if [ -f "$fichier_csv" ]; then 
    mv "$fichier_csv" input/ # Déplacement du fichier CSV dans le répertoire input/
fi

# Fin du script
echo "Traitement terminé." # Affichage d'un message de fin de traitement
