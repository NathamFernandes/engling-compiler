#ifndef RUNTIME_H
#define RUNTIME_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

typedef struct {
    void *dados;
    int tamanho;
} Vetor;

static inline Vetor criar_vetor(int tam, size_t elem_size) {
    Vetor v;
    v.dados = calloc(tam, elem_size);
    v.tamanho = tam;
    return v;
}

#endif