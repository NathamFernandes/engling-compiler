#ifndef TIPOS_H
#define TIPOS_H

typedef enum {
    /* Tipos Primitivos */
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
    T_VAZIO,
    T_ERRO,
    TOTAL_TIPOS
} CategoriaTipo;

typedef struct Tipo {
    CategoriaTipo categoria;
    char *nome_tipo;
    struct Tipo *subtipo;
} Tipo;

Tipo *criar_tipo(CategoriaTipo categoria, const char *nome_tipo, Tipo *subtipo);
Tipo *clonar_tipo(Tipo *t);
int tipos_compativeis(Tipo *tipo1, Tipo *tipo2);
void liberar_tipo(Tipo *t);

#endif