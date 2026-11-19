#ifndef HELPER_H
#define HELPER_H

#define TOTAL_TIPOS 13

#include <string>

typedef enum {
    T_INTEIRO,
    T_FLUTUANTE,
    T_DECIMAL,
    T_CARACTER,
    T_TEXTO,
    T_BOOLEANO,

    /* Estruturas Nativas */
    T_FILA,
    T_PILHA,
    T_DEQUE,
    T_CONJUNTO,
    T_GRAFO,

    /* Tipos Compostos e Especiais */
    T_VETOR,
    T_USUARIO,
} CategoriaTipo; 



char *validateType(const char *atrType, const char *exprType);

#endif