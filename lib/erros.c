#include "erros.h"
#include <stdio.h>

static int contagemErros[3] = { 0, 0, 0 };

static const char *strErro[] = {
    "erro léxico",
    "erro sintático",
    "erro semantico",
};

void printErro(TipoErro tipoErro, int linha) {
    contagemErros[tipoErro]++;

    fprintf(stderr, "linha %d: %s: ", linha, strErro[tipoErro]);
    fprintf(stderr, "\n");
}

int totalErros() {
    return contagemErros[0] + contagemErros[1] + contagemErros[2];
}

int totalErroTipo(TipoErro tipoErro) {
    return contagemErros[tipoErro];
}
