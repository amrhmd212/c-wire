#include "construire_avl.h"
#include "verif.h"
#include "equilibrage_avl.h"

// Fonction pour créer un nœud AVL
AVL* creer_AVL(int id, long capacite, long consommation) {
    if(id<=0 || capacite<0 || consommation<0){
        gestion_erreur("creer_AVL", "probleme d id ou capacite ou consomation au niveau des arguments de la fonction");
    }
    AVL* nouveau = (AVL*)malloc(sizeof(AVL));
    if (nouveau == NULL) {
        gestion_erreur("creer_AVL", "Allocation mémoire échouée");
    }

    nouveau->id = id;
    nouveau->capacite = capacite;
    nouveau->consommation = consommation;
    nouveau->equilibre = 0;
    nouveau->fg = NULL;
    nouveau->fd = NULL;

    return nouveau;
}
// Insérer un nœud dans l'AVL
AVL* insertionAVL(AVL* a, int* h, int id, long capacite, long consommation) {
    if(id<=0 || capacite<0 || consommation<0){
        gestion_erreur("insertionAVL", "probleme d id ou apacite ou consomation éu niveau des arguments de la fonction");
    }
    if (a == NULL) {
        *h = 1;
        return creer_AVL(id, capacite, consommation);
    }

    if (id < a->id) {
        a->fg = insertionAVL(a->fg, h, id, capacite, consommation);
        *h = -(*h);
    } else if (id > a->id) {
        a->fd = insertionAVL(a->fd, h, id, capacite, consommation);
    } else {
        if(capacite==0){
            a->capacite += capacite;
        }
        a->consommation += consommation;
        *h = 0;
        return a;
    }

    if (*h != 0) {
        a->equilibre += *h;
        a = equilibrerAVL(a);
        if (a->equilibre == 0) *h = 0;
    }

    return a;
}

// Fonction construire l'AVL 
AVL* construire_AVL() {
    AVL* racine = NULL;
    char ligne[1024];
    int h;

    // Lire depuis stdin (sortie d'un autre programme shell)
    while (fgets(ligne, sizeof(ligne), stdin)) {
        int id,consomateur;
        long capacite = 0, consommation = 0;

        sscanf(ligne, "%d;%d;%ld;%ld", &id ,&consomateur, &capacite, &consommation);

        racine = insertionAVL(racine, &h, id, capacite, consommation);
    }

    return racine;
}

void parcours_infixe(AVL* a, FILE* sortie,int* z) {
    static int entete_ecrit = 0;  // Variable statique pour s'assurer que l'entête est écrit une seule fois
    if(*z==0){
        (*z)++;
        if (!entete_ecrit) {
        // Ouverture du fichier contenant l'entête
        FILE* entete = fopen("tmp/temptete.dat", "r");
        if (entete == NULL) {
            gestion_erreur("parcours_infixe", "Impossible d'ouvrir le fichier 'temptete.dat'");
        }
        // Copier uniquement la première ligne du fichier 'temptete.dat' dans le fichier de sortie
            char ligne[1024];
        if (fgets(ligne, sizeof(ligne), entete)) { // Lire une seule ligne
            fputs(ligne, sortie); // Écrire cette ligne dans le fichier de sortie
            //fputc('\n', sortie);  // Ajouter un saut de ligne
        }
            fclose(entete);
            entete_ecrit = 1; // Marquer que l'entête a été écrit
        }
    }

    if (a == NULL) {
        return;
    }
    parcours_infixe(a->fg, sortie,z); // Visite du sous-arbre gauche
    fprintf(sortie, "%d;%ld;%ld\n", a->id, a->capacite, a->consommation); // Traitement du nœud courant
    parcours_infixe(a->fd, sortie,z); // Visite du sous-arbre droit
}