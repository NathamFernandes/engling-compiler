#include "semantica.h"
#include "record.h"
#include <string.h>

static int matriz_coercao[TOTAL_TIPOS][TOTAL_TIPOS] = {
    [T_INTEIRO][T_INTEIRO]       = 1,
    [T_FLUTUANTE][T_FLUTUANTE]   = 1,
    [T_FLUTUANTE][T_INTEIRO]     = 1,
    [T_DECIMAL][T_DECIMAL]       = 1,
    [T_DECIMAL][T_INTEIRO]       = 1,
    [T_DECIMAL][T_FLUTUANTE]     = 1,
    [T_CARACTER][T_CARACTER]     = 1,
    [T_TEXTO][T_TEXTO]           = 1,
    [T_TEXTO][T_CARACTER]        = 1,
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
    if (tipo1->categoria == T_ERRO || tipo2->categoria == T_ERRO) return 1;

    if (tipo1->categoria == T_USUARIO && tipo2->categoria == T_USUARIO) {
        return strcmp(tipo1->nome_tipo, tipo2->nome_tipo) == 0;
    }

    if (tipo1->subtipo != NULL || tipo2->subtipo != NULL) {
        if (tipo1->categoria != tipo2->categoria) return 0;
        return tipos_compativeis(tipo1->subtipo, tipo2->subtipo);
    }

    return matriz_coercao[tipo1->categoria][tipo2->categoria];
}

void liberar_tipo(Tipo *t) {
    if (t == NULL) return;
    liberar_tipo(t->subtipo);
    free(t->nome_tipo);
    free(t);
}

const char *tipo_para_c(Tipo *t) {
    if (!t) return "void";
    switch (t->categoria) {
        case T_INTEIRO:
        case T_BOOLEANO:  return "int";
        case T_FLUTUANTE: return "float";
        case T_DECIMAL:   return "double";
        case T_CARACTER:  return "char";
        case T_TEXTO:     return "char*";
        case T_VETOR:     return "Vetor";
        case T_USUARIO:   return t->nome_tipo ? t->nome_tipo : "void";
        default:          return "int";
    }
}

const char *especificador_tipo(Tipo *t) {
    if (!t) return "";
    switch (t->categoria) {
        case T_INTEIRO:
        case T_BOOLEANO:  return "%d";
        case T_FLUTUANTE: return "%f";
        case T_DECIMAL:   return "%lf";
        case T_CARACTER:  return "%c";
        case T_TEXTO:     return "%s";
        default:          return "";
    }
}

bool verificarCondicaoBool(record *condicao, const char *construcao, int linha) {
    if (condicao == NULL || condicao->type == NULL)
        return false;

    if (condicao->type->categoria == T_ERRO)
        return true;

    CategoriaTipo c = condicao->type->categoria;
    bool aceita = (c == T_BOOLEANO || c == T_INTEIRO);

    if (!aceita) {
        printErro(ERRO_SEMANTICO, linha, "condicao do '%s' deve ser booleana.", construcao);
    }

    return aceita;
}