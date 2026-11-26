#ifndef SEMANTICA_H
#define SEMANTICA_H

#include <stdbool.h>
#include <stdlib.h>

typedef enum {
    T_INTEIRO,
    T_FLUTUANTE,
    T_DECIMAL,
    T_CARACTER,
    T_TEXTO,
    T_BOOLEANO,
    T_FILA,
    T_PILHA,
    T_DEQUE,
    T_CONJUNTO,
    T_GRAFO,
    T_VETOR,
    T_USUARIO,
    T_VAZIO,
    T_ERRO,
    TOTAL_TIPOS
} CategoriaTipo;

typedef struct Tipo {
    CategoriaTipo categoria;
    char *nome_tipo;
    struct Tipo *subtipo;
} Tipo;

typedef struct record record; 

#include "erros.h"

/* Gerenciamento de Tipos */
Tipo *criar_tipo(CategoriaTipo categoria, const char *nome_tipo, Tipo *subtipo);
Tipo *clonar_tipo(Tipo *t);
int tipos_compativeis(Tipo *tipo1, Tipo *tipo2);
void liberar_tipo(Tipo *t);

/* Conversões e Validações Semânticas */
const char *tipo_para_c(Tipo *t);
const char *especificador_tipo(Tipo *t);
bool verificarCondicaoBool(record *condicao, const char *construcao, int linha);

#endif