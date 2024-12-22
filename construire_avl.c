#include "construire_avl.h"
#include "verif.h"
#include "equilibrage_avl.h"

// Fonction pour créer un nœud AVL
AVL* creer_AVL(int id, long capacite, long consommation) {
    if(id<=0 || capacite<0 || consommation<0){//verfication des données d'entrées.
        gestion_erreur("creer_AVL", "probleme d id ou capacite ou consomation au niveau des arguments de la fonction");//message d erreur.
    }
    AVL* nouveau = (AVL*)malloc(sizeof(AVL));//allocation dynamique de la mémoire pour l'avl.
    if (nouveau == NULL) {//verfication de l'allocation dynamique.
        gestion_erreur("creer_AVL", "Allocation mémoire échouée");//messaage d erreur.
    }

    nouveau->id = id;//initialisation de l'id.
    nouveau->capacite = capacite;//inialisation de la capacite.
    nouveau->consommation = consommation;//initalisation de la consommation.
    nouveau->equilibre = 0;//iniatialisation de l'equilibre.
    nouveau->fg = NULL;//iniatialisation du fils gauche.
    nouveau->fd = NULL;//iniatialisation du fils droit.

    return nouveau;//retiurn de l'avl.
}
// Insérer un nœud dans l'AVL
AVL* insertionAVL(AVL* a, int* h, int id, long capacite, long consommation) {
    if(id<=0 || capacite<0 || consommation<0){//veirfication des données d'entrées.
        gestion_erreur("insertionAVL", "probleme d id ou apacite ou consomation éu niveau des arguments de la fonction");//mssage d erreur.
    }
    if (a == NULL) {//verfication si il existe un avl.
        *h = 1;//mise a jour de l'hauteur.
        return creer_AVL(id, capacite, consommation);//creation d'un avl.
    }

    if (id < a->id) {//verifiction si l'id est inferieur a l'id de l'avl.
        a->fg = insertionAVL(a->fg, h, id, capacite, consommation);//insertion du fils gauche.
        *h = -(*h);//mise a jour de l'hauteur.
    }
    
    else if (id > a->id) {//verifiction si l'id est superieur a l'id de l'avl.
        a->fd = insertionAVL(a->fd, h, id, capacite, consommation);//insertion du fils droit.
    } 
    
    else {
        if(capacite==0){//verifiction si la capacite est egale a 0.
            a->capacite += capacite;//ajout de la capacite.
        }
        a->consommation += consommation;//ajout de la consommation.
        *h = 0;//mise a jour de l'hauteur.
        return a;//retourn de l'avl.
    }

    if (*h != 0) {//verifiction si l'hauteur est different de 0.
        a->equilibre += *h;//mise a jour de l'equilibre.
        a = equilibrerAVL(a);//equilibrage de l'avl.
        if (a->equilibre == 0){//verifiction si l'equilibre est egale a 0.
            *h = 0;//mise a jour de l'hauteur.
        }
    }

    return a;//retourn de l'avl.
}

// Fonction construire l'AVL 
AVL* construire_AVL() {
    AVL* racine = NULL;//initialisation de la racine.
    char ligne[1024];//initialisation de la ligne afin de lire le fichier
    int h;//initialisation de l'hauteur.

    // Lire un fichier (sortie d'un autre programme shell)
    while (fgets(ligne, sizeof(ligne), stdin)) {//lecture de la ligne.
        int id,consomateur;//declaration de l'id et du consomateur.
        long capacite = 0, consommation = 0;//initialisation de la capacite et de la consommation.

        sscanf(ligne, "%d;%d;%ld;%ld", &id ,&consomateur, &capacite, &consommation);//on recupere les données de la ligne.

        racine = insertionAVL(racine, &h, id, capacite, consommation);//insertion de l'avl.
    }

    return racine;//retourn de l'avl.
}

// Fonction pour afficher l'AVL en parcours infixe.
void parcours_infixe(AVL* a, FILE* sortie,int* z) {
    if (sortie == NULL) {//verifiction si le fichier de sortie existe.
        gestion_erreur("parcours_infixe", "Fichier de sortie non valide");//message d erreur.
        return;//retour de la fonction.
    } 
    static int entete_ecrit = 0;  // Variable statique pour s'assurer que l'entête est écrit une seule fois
    if(*z==0){//verifiction si l'entete n'a pas deja ete ecrit.
        (*z)++;//ajout de z.
        if (!entete_ecrit) {//verifiction si l'entete n'a pas deja ete ecrit.
            FILE* entete = fopen("tmp/temptete.dat", "r");// Ouverture du fichier contenant l'entête
            if (entete == NULL) {//verfication de l'ouverture du fichier.
            gestion_erreur("parcours_infixe", "Impossible d'ouvrir le fichier 'temptete.dat'");//message d erreur.
            }
            // ici on va copier uniquement la première ligne du fichier 'temptete.dat' dans le fichier de sortie
            char ligne[1024];
            if (fgets(ligne, sizeof(ligne), entete)) { // Lire une seule ligne
                fputs(ligne, sortie); // Écrire cette ligne dans le fichier de sortie
            
            }
            fclose(entete);//fermeture du fichier.
            entete_ecrit = 1; // Marquer que l'entête a été écrit
        }
    }

    if (a == NULL) {//verifiction si l'avl existe.
        return;//retourn de la fonction.
    }
    parcours_infixe(a->fg, sortie,z); // Visite du sous-arbre gauche
    fprintf(sortie, "%d;%ld;%ld\n", a->id, a->capacite, a->consommation); // Traitement du nœud courant
    parcours_infixe(a->fd, sortie,z); // Visite du sous-arbre droit
}
