#include "main.h"

// Fonction main pour lire depuis stdin
int main(){
    FILE* sortie;//initialisation du fichier de sortie.
    int z = 0;//initialisation de z.

    // Ouvrir le fichier de sortie (resultat.csv)
    sortie = fopen("tests/resultat.csv", "w");//ouverture du fichier de sortie.
    if (sortie == NULL) {//verfication de l'ouverture du fichier.
        gestion_erreur("main", "Erreur lors de l'ouverture du fichier de sortie");//message d erreur.
        return 1;//retour de 1.
    }

    AVL* racine = construire_AVL();//initialisation de la racine.

    parcours_infixe(racine, sortie, &z);//appel de la fonction parcours infixe.
    fclose(sortie);//fermeture du fichier de sortie.

    liberer_AVL(racine);//appel de la fonction liberer_AVL pour liberer la memoire.

    return EXIT_SUCCESS;//retour du programme
}
