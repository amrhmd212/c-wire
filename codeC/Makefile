# Variables pour le compilateur et les options
CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c11 -g
LDFLAGS = 

# Noms des fichiers sources et objets
SRCS = main.c construire_avl.c equilibrage_avl.c verif.c
OBJS = $(SRCS:.c=.o)
TARGET = avl_program

# Règle par défaut
all: $(TARGET)

# Création de l'exécutable
$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

# Compilation des fichiers objets
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nettoyage des fichiers générés
clean:
	rm -f $(OBJS) $(TARGET)

# Nettoyage complet (avec fichiers temporaires)
distclean: clean
	rm -f tests/resultat.csv tmp/temptete.dat

# Pour marquer ces règles comme non liées à des fichiers
.PHONY: all clean distclean
