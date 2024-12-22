#include "equilibrage_avl.h"
#include "verif.h"

// Rotation simple gauche
AVL* rotation_simple_gauche(AVL* a) {
    if (a == NULL || a->fd == NULL) {//verifiction si l'avl existe et si le fils droit existe.
        gestion_erreur("rotation_simple_gauche", "Nœud ou sous-arbre droit manquant");//message d erreur.
    }

    AVL* pivot = a->fd;//initialisation du pivot.
    a->fd = pivot->fg;//mise a jour du fils droit de a.
    pivot->fg = a;//mise a jour du fils gauche du pivot.

    int eq_a=a->equilibre;//initialisation de l'equilibre de a.
    int eq_p=pivot->equilibre;//initialisation de l'equilibre de pivot.

    a->equilibre=eq_a-max(eq_p,0)-1;//mise a jour de l'equilibre de a.
    pivot->equilibre=min3(eq_a-2,eq_a+eq_p-2,eq_p-1);//mise a jour de l'equilibre de pivot.
    return pivot;//retourn de pivot.
}

// Rotation simple droite
AVL* rotation_simple_droite(AVL* a) {
    if (a == NULL || a->fg == NULL) {//verifiction si l'avl existe et si le fils gauche existe.
        gestion_erreur("rotation_simple_droite", "Nœud ou sous-arbre gauche manquant");//message d erreur.
    }

    AVL* pivot = a->fg;//initialisation du pivot.
    a->fg = pivot->fd;//mise a jour du fils gauche de a.
    pivot->fd = a;//mise a jour du fils droit du pivot.

    int eq_a=a->equilibre;//initialisation de l'equilibre de a.
    int eq_p=pivot->equilibre;//initialisation de l'equilibre de pivot.

    a->equilibre=eq_a-min(eq_p,0)+1;//mise a jour de l'equilibre de a.
    pivot->equilibre=max3(eq_a+2,eq_a+eq_p+2,eq_p+1);//mise a jour de l'equilibre de pivot.
    return pivot;//retourn de pivot.
}

// Fonction pour trouver le minimum entre deux nombres
int min(int a, int b) {
    if (a < b) {//verifiction si a est inferieur a b.
        return a;//retourn de a.
    } 
    else {
        return b;//retourn de b.
    }
}

// Fonction pour trouver le maximum entre deux nombres
int max(int a, int b) {
    if (a > b) {//verifiction si a est superieur a b.
        return a;//retourn de a.
    } 
    else {
        return b;//retourn de b.
    }
}

// Fonction pour trouver le maximum entre trois nombres
int max3(int a, int b, int c) {
    int d = max(a, b);//initialisation de d avec le max entre a et b.
    if (c > d) {//verifiction si c est superieur a d.
        return c;//retourn de c.
    } 
    else {
        return d;//retourn de d.
    }
}

// Fonction pour trouver le minimum entre trois nombres
int min3(int a, int b, int c) {
    int d = min(a, b);//initialisation de d avec le min entre a et b.
    if (c < d) {//verifiction si c est inferieur a d.
        return c;//retourn de c.
    } 
    else {
        return d;//retourn de d.
    }
}

// Rotation double gauche
AVL* rotation_double_gauche(AVL* a) {
    if (a == NULL || a->fd == NULL) {//verifiction si l'avl existe et si le fils droit existe.
        gestion_erreur("rotation_double_gauche", "Sous-arbre droit manquant");//message d erreur.
    }
    a->fd = rotation_simple_droite(a->fd);//rotation simple droite du fils droit de a.
    return rotation_simple_gauche(a);//rotation simple gauche de a.
}

// Rotation double droite
AVL* rotation_double_droite(AVL* a) {
    if (a == NULL || a->fg == NULL) {//verifiction si l'avl existe et si le fils gauche existe.
        gestion_erreur("rotation_double_droite", "Sous-arbre gauche manquant");//message d erreur.
    }
    a->fg = rotation_simple_gauche(a->fg);//rotation simple gauche du fils gauche de a.
    return rotation_simple_droite(a);//rotation simple droite de a.
}

// Équilibrer un AVL
AVL* equilibrerAVL(AVL* a) {
    if (a == NULL) {//verifiction si l'avl existe.
        gestion_erreur("equilibrerAVL", "Nœud AVL inexistant");//message d erreur.
    }

    if (a->equilibre >= 2) {//verifiction si l'equilibre de a est superieur ou egale a 2.
        if (a->fd->equilibre >= 0) {//verifiction si l'equilibre du fils droit de a est superieur ou egale a 0
            return rotation_simple_gauche(a);//rotation simple gauche de a.
        } 
        else {
            return rotation_double_gauche(a);//rotation double gauche de a.
        }
        
    }
    else if (a->equilibre <= -2) {//verifiction si l'equilibre de a est inferieur ou egale a -2.
        if (a->fg->equilibre <= 0) {//verifiction si l'equilibre du fils gauche de a est inferieur ou egale a
            return rotation_simple_droite(a);//rotation simple droite de a.
        } 
        else {
            return rotation_double_droite(a);//rotation double droite de a.
        }
    }
    return a;//retourn de a.
}
