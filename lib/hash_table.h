#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#include "pilha.h"
#include "semantica.h"

#define TAMANHO_TABELA 101

typedef enum {
    CAT_VARIAVEL,
    CAT_CONSTANTE,
    CAT_FUNCAO,
    CAT_PROCEDIMENTO,
    CAT_TIPO_USUARIO
} categoriaSimbolo;

typedef struct simbolo {
    char *chave;
    char *nome;
    Tipo *tipo;
    categoriaSimbolo categoria;
    int linha_declaracao;
    struct simbolo *proximo;
} simbolo;

typedef struct HashTable {
    simbolo *baldes[TAMANHO_TABELA];
} HashTable;

HashTable *criar_tabela(void);
int inserir_simbolo(HashTable *ht, pilha *p, const char *nome, Tipo *tipo, categoriaSimbolo cat, int linha_declaracao);
simbolo *buscar_simbolo(HashTable *ht, pilha *p, const char *nome);
void liberar_tabela(HashTable *ht);

#endif