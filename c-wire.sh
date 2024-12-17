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

# Vérification et compilation du programme C
if [ ! -f "main.c" ]; then
    echo "Erreur : Fichier 'main.c' introuvable."
    exit 1
fi

make clean
make
if [ $? -ne 0 ]; then
    echo "Erreur : Échec de la compilation du programme C."
    exit 1
fi
echo "Compilation réussie. Exécutable généré : ./main ou ./avl_program"

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Erreur : Nombre insuffisant d'arguments."
    echo "Durée totale de traitement : 0.0s"
    afficher_aide
fi

# Arguments
fichier_csv="$1"
type_station="$2"
type_consommateur="$3"
id_centrale="$4"

# Vérification des types de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Type de station invalide. Utilisez 'hvb', 'hva', ou 'lv'."
    echo "Durée totale de traitement : 0.0s"
    afficher_aide
fi

# Vérification des types de consommateur
if [[ "$type_station" == "hvb" && "$type_consommateur" != "comp" ]]; then
    echo "Erreur : Pour 'hvb', seul 'comp' est autorisé."
    echo "Durée totale de traitement : 0.0s"
    afficher_aide
fi

if [[ "$type_station" == "hva" && "$type_consommateur" != "comp" ]]; then
    echo "Erreur : Pour 'hva', seul 'comp' est autorisé."
    echo "Durée totale de traitement : 0.0s"
    afficher_aide
fi

if [[ "$type_station" == "lv" && "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide pour 'lv'."
    echo "Durée totale de traitement : 0.0s"
    afficher_aide
fi

# Vérification de la présence du fichier CSV
if [ ! -f "$fichier_csv" ]; then
    echo "Erreur : Le fichier '$fichier_csv' n'existe pas."
    echo "Durée totale de traitement : 0.0s"
    exit 1
fi

# Création des dossiers nécessaires
mkdir -p input tmp graphs tests


# Gestion de l'identifiant de centrale
filtre_centrale=""
if [ -n "$id_centrale" ]; then
    filtre_centrale="\$1 == \"$id_centrale\" &&"
fi


# Traitement des cas selon les types de station et de consommateur
if [[ "$type_station" == "hvb" && "$type_consommateur" == "comp" ]]; then
    # Créer/écrire l'en-tête dans tmp/temptete.dat
    echo "Station HV-B;Capacité;Conso comp" > tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then
echo "Exécution : ./main avec les données traitées du fichier 1 $fichier_csv"
        cat "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$2 != \"-\" && \$4 == \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 == \"-\" && \$4 == \"-\" && \$5 == \"-\" && \$6 == \"-\"" | \
        cut -d';' -f2,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
 echo "Résultats enregistrés dans tests/resultat.csv"
    else
        grep -E "^$id_centrale;" "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$2 != \"-\" && \$4 == \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 == \"-\" && \$4 == \"-\" && \$5 == \"-\" && \$6 == \"-\"" | \
        cut -d';' -f2,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    fi
    mv tests/resultat.csv tests/hvb_comp_resultat.csv

elif [[ "$type_station" == "hva" && "$type_consommateur" == "comp" ]]; then
    # Créer/écrire l'en-tête dans tmp/temptete.dat
    echo "Station HV-A;Capacité;Conso (entreprise)" > tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then
echo "Exécution : ./main avec les données traitées du fichier2 $fichier_csv"
        cat "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$3 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 != \"-\" && \$4 == \"-\"" | \
        cut -d';' -f3,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    else
        grep -E "^$id_centrale;" "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$3 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$2 != \"-\" && \$3 != \"-\" && \$4 == \"-\"" | \
        cut -d';' -f3,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    fi
    mv tests/resultat.csv tests/hva_comp_resultat.csv

elif [[ "$type_station" == "lv" && "$type_consommateur" == "comp" ]]; then
    # Créer/écrire l'en-tête dans tmp/temptete.dat
    echo "Station LV;Capacité;Conso (entreprise)" > tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then
echo "Exécution : ./main avec les données traitées du fichier3 $fichier_csv"
        cat "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    else
        grep -E "^$id_centrale;" "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,5,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    fi
    mv tests/resultat.csv tests/lv_comp_resultat.csv


elif [[ "$type_station" == "lv" && "$type_consommateur" == "indiv" ]]; then
    # Créer/écrire l'en-tête dans tmp/temptete.dat
    echo "Station LV;Capacité;Conso (particuliers)" > tmp/temptete.dat
    if [[ -z "$id_centrale" ]]; then
echo "Exécution : ./main avec les données traitées du fichier4 $fichier_csv"
        cat "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,6,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    else
        grep -E "^$id_centrale;" "$fichier_csv" | \
        awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
        cut -d';' -f4,6,7,8 | tr '-' '0' | ./avl_program > tests/resultat.csv
echo "Résultats enregistrés dans tests/resultat.csv"
    fi
    mv tests/resultat.csv tests/lv_indiv_resultat.csv

elif [[ "$type_station" == "lv" && "$type_consommateur" == "all" ]]; then
echo "Station LV;Capacité;Conso (Tous)" > tmp/temptete.dat
echo "Exécution pour LV (tous les consommateurs)"

# Filtre pour "comp" (entreprises)
comp_file="tmp/comp_data.csv"
if [[ -z "$id_centrale" ]]; then
    cat "$fichier_csv" | \
    awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
    cut -d';' -f4,5,7,8 | tr '-' '0' > "$comp_file"
else
    grep -E "^$id_centrale;" "$fichier_csv" | \
    awk -F';' "$filtre_centrale \$4 != \"-\" && \$5 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
    cut -d';' -f4,5,7,8 | tr '-' '0' > "$comp_file"
fi

# Vérification du fichier comp_data.csv
if [ ! -s "$comp_file" ]; then
    echo "Erreur : Le fichier $comp_file est vide ou n'a pas été créé. Vérifiez les filtres."
    exit 1
fi
echo "Résultats partiels enregistrés dans $comp_file"

# Filtre pour "indiv" (particuliers)
indiv_file="tmp/indiv_data.csv"
if [[ -z "$id_centrale" ]]; then
    cat "$fichier_csv" | \
    awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
    cut -d';' -f4,6,7,8 | tr '-' '0' > "$indiv_file"
else
    grep -E "^$id_centrale;" "$fichier_csv" | \
    awk -F';' "$filtre_centrale \$4 != \"-\" && \$6 != \"-\" && \$7 == \"-\" || \$3 != \"-\" && \$4 != \"-\" && \$8 == \"-\"" | \
    cut -d';' -f4,6,7,8 | tr '-' '0' > "$indiv_file"
fi

# Vérification du fichier indiv_data.csv
if [ ! -s "$indiv_file" ]; then
    echo "Erreur : Le fichier $indiv_file est vide ou n'a pas été créé. Vérifiez les filtres."
    exit 1
fi
echo "Résultats partiels enregistrés dans $indiv_file"

# Combinaison des deux fichiers
combined_file="tmp/all_data.csv"
cat "$comp_file" "$indiv_file" > "$combined_file"
if [ ! -s "$combined_file" ]; then
    echo "Erreur : Le fichier combiné $combined_file est vide."
    exit 1
fi
echo "Combinaison des résultats dans $combined_file"

# Exécution du programme C
./avl_program < "$combined_file" > tests/resultat.csv
if [ ! -s tests/resultat.csv ]; then
    echo "Erreur : Le fichier tests/resultat.csv n'a pas été généré."
    exit 1
fi

# Renommer le fichier de sortie
mv tests/resultat.csv tests/lv_all_resultat.csv
echo "Résultats enregistrés dans tests/lv_all_resultat.csv"


# Extraire les top et bottom 5
extract_top_5() {
    local input_csv="tests/lv_all_resultat.csv"
    local output_csv="tests/all_min_max.csv"
    if [ ! -f "$input_csv" ]; then
        echo "Erreur : Le fichier '$input_csv' n'existe pas."
        exit 1
    fi
    # Ajouter l'en-tête avant d'écrire les données
    echo "Station LV ;Capacité;Conso (tous)" > "$output_csv"
    awk -F';' 'NR > 1 {
        diff = $3 - $2; 
        print $1 ";" $2 ";" $3 ";" diff
    }' "$input_csv" | sort -t';' -k4,4nr | head -n 5 | cut -d';' -f1-3 >> "$output_csv"

    echo "Les 5 plus grands nombres de la 3e colonne ont été sauvegardés dans $output_csv."
}

extract_bottom_5() {
    local input_csv="tests/lv_all_resultat.csv"
    local output_csv="tests/all_min_max.csv"

    if [ ! -f "$input_csv" ]; then
        echo "Erreur : Le fichier '$input_csv' n'existe pas."
        exit 1
    fi

    awk -F';' 'NR > 1 && $3 > $2 {
        diff = $3 - $2;
        print $1 ";" $2 ";" $3 ";" diff
    }' "$input_csv" | sort -t';' -k4,4nr | tail -n 5 | cut -d';' -f1-3 >> "$output_csv"

    echo "Les 5 stations avec les plus petites différences (consommation-capacité) ont été ajoutées à $output_csv."
}

generate_graph() {
    local data_file="tests/all_min_max.csv"
    local plot_file="graphs/graph.png"  # Modifier ici pour stocker dans le dossier 'graphs'

    # Vérifier que Gnuplot est installé
    if ! command -v gnuplot &> /dev/null; then
        echo "Erreur : Gnuplot n'est pas installé."
        exit 1
    fi

    # Générer un graphique avec Gnuplot
    gnuplot <<-EOF
        set terminal png size 1200,800
        set output '${plot_file}'
        set title "Postes LV les plus et les moins chargés"
        set xlabel "Postes LV"
        set ylabel "Consommation (kWh)"
        set boxwidth 0.8
        set style fill solid
        set grid ytics
        set datafile separator ';'

        # Définir les couleurs : rouge pour consommation > capacité, vert sinon
        set style line 1 lc rgb "red"
        set style line 2 lc rgb "green"

        # Légende explicite
        set key outside top center
        set style data histogram
        set style histogram cluster gap 1
        set xtic rotate by -45 scale 0

        # Tracé des données
        plot \
        '${data_file}' using 2:xtic(1) title "Capacité" with histograms ls 2, \
        '' using 3 title "Consommation" with histograms ls 1
EOF

    echo "Le graphique a été généré dans le fichier '${plot_file}'."
}

# Exécuter les fonctions pour lv et all
    extract_top_5
    extract_bottom_5
    generate_graph
else
    echo "Erreur : Combinaison d'arguments invalide."
    echo "Durée totale de traitement : 0.0s"
    exit 1
fi

# Fin du chronomètre et affichage de la durée
end_time=$(date +%s.%N)
elapsed_time=$(awk "BEGIN {print $end_time - $start_time}")
echo "Durée totale de traitement : ${elapsed_time}s"

# Nettoyage des fichiers temporaires
#rm -rf tmp/*

#mv "$fichier_csv" input/
# Fin du script
echo "Traitement terminé."
