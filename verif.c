
#include "verif.h"

// Gestion des erreurs personnalisée
void gestion_erreur(const char* fonction, const char* cause) {
    fprintf(stderr, "Erreur dans la fonction '%s' : %s\n", fonction, cause);
    exit(EXIT_FAILURE);
}

// Libérer l'AVL
void liberer_AVL(AVL* a) {
    if (a == NULL) {
        return;
    }
    liberer_AVL(a->fg);
    liberer_AVL(a->fd);
    free(a);
}