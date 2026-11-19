#include "tipos.h"
#include <stdlib.h>
#include <string.h>

static int matriz_coercao[TOTAL_TIPOS][TOTAL_TIPOS] = {
    /* [DESTINO][ORIGEM] = 1 */
    [T_INTEIRO][T_INTEIRO]       = 1,
    [T_FLUTUANTE][T_FLUTUANTE]   = 1,
    [T_FLUTUANTE][T_INTEIRO]     = 1, // Flutuante <- Inteiro
    [T_DECIMAL][T_DECIMAL]       = 1,
    [T_DECIMAL][T_INTEIRO]       = 1, // Decimal <- Inteiro
    [T_DECIMAL][T_FLUTUANTE]     = 1, // Decimal <- Flutuante
    [T_CARACTER][T_CARACTER]     = 1,
    [T_TEXTO][T_TEXTO]           = 1,
    [T_TEXTO][T_CARACTER]        = 1, // Texto <- Caracter
    [T_BOOLEANO][T_BOOLEANO]     = 1,
};

Tipo *criar_tipo(CategoriaTipo categoria, const char *nome_tipo, Tipo *subtipo) {
    Tipo *t = (Tipo *) malloc(sizeof(Tipo));
    if (t != NULL) {
        t->categoria = categoria;
        t->nome_tipo = nome_tipo ? strdup(nome_tipo) : NULL;
        t->subtipo = subtipo;
    }
    return t;
}

Tipo *clonar_tipo(Tipo *t) {
    if (t == NULL) return NULL;
    return criar_tipo(t->categoria, t->nome_tipo, clonar_tipo(t->subtipo));
}

int tipos_compativeis(Tipo *tipo1, Tipo *tipo2) {
    if (tipo1 == NULL || tipo2 == NULL) return 0;

    // Evita cascata de erros se um dos lados já falhou antes
    if (tipo1->categoria == T_ERRO || tipo2->categoria == T_ERRO) return 1;

    // Tipos definidos pelo usuário (structs)
    if (tipo1->categoria == T_USUARIO && tipo2->categoria == T_USUARIO) {
        return strcmp(tipo1->nome_tipo, tipo2->nome_tipo) == 0;
    }

    // Tipos compostos (vetor<T>, pilha<T>, fila<T>, etc.)
    if (tipo1->subtipo != NULL || tipo2->subtipo != NULL) {
        if (tipo1->categoria != tipo2->categoria) return 0;
        return tipos_compativeis(tipo1->subtipo, tipo2->subtipo);
    }

    // Caso base (primitivos)
    return matriz_coercao[tipo1->categoria][tipo2->categoria];
}

void liberar_tipo(Tipo *t) {
    if (t == NULL) return;
    liberar_tipo(t->subtipo);
    free(t->nome_tipo);
    free(t);
}