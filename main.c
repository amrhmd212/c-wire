#include "main.h"

// Fonction main pour lire depuis stdin
int main(){
    FILE* sortie;
    int z = 0;

    // Ouvrir le fichier de sortie (resultat.csv)
    sortie = fopen("tests/resultat.csv", "w");
    if (sortie == NULL) {
        gestion_erreur("main", "Erreur lors de l'ouverture du fichier de sortie");
        return 1;
    }

    // Construire l'AVL à partir de stdin
    AVL* racine = construire_AVL();

    // Écrire le résultat dans stdout
    parcours_infixe(racine, sortie, &z);
    fclose(sortie);

    // Libérer la mémoire
    liberer_AVL(racine);

    return EXIT_SUCCESS;
}


