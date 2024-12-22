
#include "verif.h"

// Gestion des erreurs.
void gestion_erreur(const char* fonction, const char* cause) {
    fprintf(stderr, "Erreur dans la fonction '%s' : %s\n", fonction, cause);//message d erreur avec 2%s afin de personnaliser le message d erreur er fonction d'où le problème vient.
    exit(EXIT_FAILURE);//sortie du programme.
}

// Libérer l'AVL
void liberer_AVL(AVL* a) {
    if (a == NULL) {//verifiction si l'avl existe.
        return;//retourn de la fonction.
    }
    liberer_AVL(a->fg);//appel de la fonction liberer_AVL pour liberer le fils gauche.
    liberer_AVL(a->fd);//appel de la fonction liberer_AVL pour liberer le fils droit.
    free(a);//libération de la mémoire.
}
