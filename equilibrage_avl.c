#include "equilibrage_avl.h"
#include "verif.h"

// Rotation simple gauche
AVL* rotation_simple_gauche(AVL* a) {
    if (a == NULL || a->fd == NULL) {
        gestion_erreur("rotation_simple_gauche", "Nœud ou sous-arbre droit manquant");
    }

    AVL* pivot = a->fd;
    a->fd = pivot->fg;
    pivot->fg = a;

    int eq_a=a->equilibre;
    int eq_p=pivot->equilibre;

    a->equilibre=eq_a-max(eq_p,0)-1;
    pivot->equilibre=min3(eq_a-2,eq_a+eq_p-2,eq_p-1);
    return pivot;
}

// Rotation simple droite
AVL* rotation_simple_droite(AVL* a) {
    if (a == NULL || a->fg == NULL) {
        gestion_erreur("rotation_simple_droite", "Nœud ou sous-arbre gauche manquant");
    }

    AVL* pivot = a->fg;
    a->fg = pivot->fd;
    pivot->fd = a;

    int eq_a=a->equilibre;
    int eq_p=pivot->equilibre;

    a->equilibre=eq_a-min(eq_p,0)+1;
    pivot->equilibre=max3(eq_a+2,eq_a+eq_p+2,eq_p+1);
    return pivot;
}

// Fonction pour trouver le minimum entre deux nombres
int min(int a, int b) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
}

// Fonction pour trouver le maximum entre deux nombres
int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

// Fonction pour trouver le maximum entre trois nombres
int max3(int a, int b, int c) {
    int d = max(a, b); // Trouve le maximum entre a et b
    if (c > d) {       // Compare avec c
        return c;
    } else {
        return d;
    }
}

// Fonction pour trouver le minimum entre trois nombres
int min3(int a, int b, int c) {
    int d = min(a, b); // Trouve le minimum entre a et b
    if (c < d) {       // Compare avec c
        return c;
    } else {
        return d;
    }
}

// Rotation double gauche
AVL* rotation_double_gauche(AVL* a) {
    if (a == NULL || a->fd == NULL) {
        gestion_erreur("rotation_double_gauche", "Sous-arbre droit manquant");
    }
    a->fd = rotation_simple_droite(a->fd);
    return rotation_simple_gauche(a);
}

// Rotation double droite
AVL* rotation_double_droite(AVL* a) {
    if (a == NULL || a->fg == NULL) {
        gestion_erreur("rotation_double_droite", "Sous-arbre gauche manquant");
    }
    a->fg = rotation_simple_gauche(a->fg);
    return rotation_simple_droite(a);
}

// Équilibrer un AVL
AVL* equilibrerAVL(AVL* a) {
    if (a == NULL) {
        gestion_erreur("equilibrerAVL", "Nœud AVL inexistant");
    }

    if (a->equilibre >= 2) {
        if (a->fd->equilibre >= 0) {
            return rotation_simple_gauche(a);
        } else {
            return rotation_double_gauche(a);
        }
    } else if (a->equilibre <= -2) {
        if (a->fg->equilibre <= 0) {
            return rotation_simple_droite(a);
        } else {
            return rotation_double_droite(a);
        }
    }
    return a;
}