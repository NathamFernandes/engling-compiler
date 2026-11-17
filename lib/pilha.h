#ifndef PILHA_H
#define PILHA_H

typedef struct no {
    char *escopo; 
    struct no *proximo_no;
} no;

typedef struct pilha {
    no *topo;
} pilha;

pilha *criar_pilha(void);
void push(pilha *p, const char *escopo);
void pop(pilha *p);
char *escopo_atual(pilha *p);
void liberar_pilha(pilha *p);

#endif