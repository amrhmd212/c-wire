#ifndef VERIF_H
#define VERIF_H

#include <stdio.h>
#include <stdlib.h>
#include "construire_avl.h"  // Pour utiliser la structure AVL

// Fonctions de gestion et vérification
void gestion_erreur(const char* fonction, const char* cause);
void liberer_AVL(AVL* a);

#endif // VERIF_H

