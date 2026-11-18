#include "hash_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned int calcular_hash(const char *str) {
    unsigned int hash = 0;
    for (int i = 0; str[i] != '\0'; i++) {
        hash = (hash * 31) + (unsigned char) str[i];
    }
    return hash % TAMANHO_TABELA;
}

static char *montar_chave(const char *escopo, const char *nome) {
    size_t tam = strlen(escopo) + strlen(nome) + 2;
    char *chave = (char *) malloc(tam);
    if (chave != NULL) {
        sprintf(chave, "%s_%s", escopo, nome);
    }
    return chave;
}

HashTable *criar_tabela(void) {
    HashTable *ht = (HashTable *) malloc(sizeof(HashTable));
    if (ht != NULL) {
        for (int i = 0; i < TAMANHO_TABELA; i++) {
            ht->baldes[i] = NULL;
        }
    }
    return ht;
}

simbolo *buscar_simbolo(HashTable *ht, pilha *p, const char *nome) {
    if (ht == NULL || p == NULL) return NULL;

    no *cursor_escopo = p->topo;

    while (cursor_escopo != NULL) {
        char *chave = montar_chave(cursor_escopo->escopo, nome);
        unsigned int indice = calcular_hash(chave);

        simbolo *atual = ht->baldes[indice];
        while (atual != NULL) {
            if (strcmp(atual->chave, chave) == 0) {
                free(chave);
                return atual;
            }
            atual = atual->proximo;
        }

        free(chave);
        cursor_escopo = cursor_escopo->proximo_no;
    }

    return NULL;
}

int inserir_linha(HashTable *ht, pilha *p, const char *nome, const char *tipo, categoriaSimbolo cat, int linha_declaracao) {
    char *escopo = escopo_atual(p);
    if (ht == NULL || escopo == NULL) return 0;

    /* Impede redeclaração no escopo atual ou sombreamento de escopos externos */
    if (buscar_simbolo(ht, p, nome) != NULL) {
        return 0;
    }

    char *chave = montar_chave(escopo, nome);
    unsigned int indice = calcular_hash(chave);

    simbolo *novo = (simbolo *) malloc(sizeof(simbolo));
    novo->chave = chave;
    novo->nome = strdup(nome);
    novo->tipo = strdup(tipo);
    novo->categoria = cat;
    novo->linha_declaracao = linha_declaracao;

    novo->proximo = ht->baldes[indice];
    ht->baldes[indice] = novo;

    return 1;
}

void liberar_tabela(HashTable *ht) {
    if (ht == NULL) return;

    for (int i = 0; i < TAMANHO_TABELA; i++) {
        simbolo *atual = ht->baldes[i];
        while (atual != NULL) {
            simbolo *temp = atual;
            atual = atual->proximo;
            free(temp->chave);
            free(temp->nome);
            free(temp->tipo);
            free(temp);
        }
    }
    free(ht);
}