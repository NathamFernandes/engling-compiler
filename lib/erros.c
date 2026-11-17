#include <stdarg.h>
#include <stdio.h>
#include "erros.h"

static int contagemErros[3] = { 0, 0, 0 };

static const char *strErro[] = {
    "erro léxico",
    "erro sintático",
    "erro semantico",
};

void printErro(TipoErro tipoErro, int linha, const char *fmt_msg, ...) {
    va_list args;
    contagemErros[tipoErro]++;

    fprintf(stderr, "linha %d: %s: ", linha, strErro[tipoErro]);

    va_start(args, fmt_msg);
    vfprintf(stderr, fmt_msg, args);
    va_end(args);

    fprintf(stderr, "\n");
}

int totalErros() {
    return contagemErros[0] + contagemErros[1] + contagemErros[2];
}

int totalErroTipo(TipoErro tipoErro) {
    return contagemErros[tipoErro];
}
