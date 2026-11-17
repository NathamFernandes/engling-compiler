#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#include "pilha.h"

#define TAMANHO_TABELA 101

typedef enum {
    CAT_VARIAVEL,
    CAT_CONSTANTE,
    CAT_FUNCAO,
    CAT_PROCEDIMENTO,
    CAT_TIPO_USUARIO
} categoriaLinha;

typedef struct simbolo {
    char *chave;                 /* Chave composta: "escopo_nome" (ex: "global_PI") */
    char *nome;                  /* Nome original do identificador (ex: "PI") */
    char *tipo;                  /* Tipo em texto (ex: "inteiro", "vetor<inteiro>") */
    categoriaLinha categoria;    /* Se é constante, variável, função, etc. */
    int linha_declaracao;        /* Linha onde foi declarado */
    struct simbolo *proximo;     /* Próximo nó em caso de colisão no balde */
} simbolo;

typedef struct HashTable {
    simbolo *baldes[TAMANHO_TABELA];
} HashTable;

HashTable *criar_tabela(void);
int inserir_linha(HashTable *ht, pilha *p, const char *nome, const char *tipo, categoriaLinha cat, int linha_declaracao);
simbolo *buscar_simbolo(HashTable *ht, pilha *p, const char *nome);
void liberar_tabela(HashTable *ht);

#endif