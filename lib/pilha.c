#include "pilha.h"
#include <stdlib.h>
#include <string.h>

pilha *criar_pilha(void) {
    pilha *nova_pilha = (pilha *) malloc(sizeof(pilha));
    
    if (nova_pilha != NULL) {
        nova_pilha->topo = NULL;
    }
    
    return nova_pilha;
}

void push(pilha *p, const char *escopo) {
    if (p == NULL) return;

    no *novo_no = (no *) malloc(sizeof(no));
    if (novo_no == NULL) return;

    novo_no->escopo = strdup(escopo);
    novo_no->proximo_no = p->topo;

    p->topo = novo_no;
}

void pop(pilha *p) {
    if (p == NULL || p->topo == NULL) return;

    no *temp = p->topo;

    p->topo = temp->proximo_no;

    free(temp->escopo);
    free(temp);
}

char *escopo_atual(pilha *p) {
    if (p == NULL || p->topo == NULL) return NULL;
    
    return p->topo->escopo;
}

void liberar_pilha(pilha *p) {
    if (p == NULL) return;

    while (p->topo != NULL) {
        pop(p);
    }

    free(p);
}