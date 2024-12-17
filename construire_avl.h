#ifndef CONSTRUIRE_AVL_H
#define CONSTRUIRE_AVL_H

#include <stdio.h>
#include <stdlib.h>

// Structure AVL
typedef struct AVL {
    int id;
    long capacite;
    long consommation;
    int equilibre;
    struct AVL* fg; // Fils gauche
    struct AVL* fd; // Fils droit
} AVL;

// Fonctions AVL
AVL* creer_AVL(int id, long capacite, long consommation);
AVL* insertionAVL(AVL* a, int* h, int id, long capacite, long consommation);
AVL* construire_AVL();
void parcours_infixe(AVL* a, FILE* sortie, int* z);
AVL* equilibrerAVL(AVL* a);

#endif // CONSTRUIRE_AVL_H
