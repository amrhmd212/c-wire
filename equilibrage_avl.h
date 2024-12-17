#ifndef EQUILIBRAGE_AVL_H
#define EQUILIBRAGE_AVL_H

#include "construire_avl.h"

// Fonctions d'équilibrage AVL
AVL* rotation_simple_gauche(AVL* a);
AVL* rotation_simple_droite(AVL* a);
AVL* rotation_double_gauche(AVL* a);
AVL* rotation_double_droite(AVL* a);

int min(int a, int b);
int max(int a, int b);
int min3(int a, int b, int c);
int max3(int a, int b, int c);

#endif // EQUILIBRAGE_AVL_H
