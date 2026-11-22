#include <stdarg.h>
#include <stdio.h>
#include "erros.h"

static int contagemErros[3] = { 0, 0, 0 };

static const char *strErro[] = {
    "Erro Léxico",
    "Erro Sintático",
    "Erro Semântico",
};

void printErro(TipoErro tipoErro, int linha, const char *fmt_msg, ...) {
    // guarda a lista de parametros extras definidas em '...'
    va_list args;

    contagemErros[tipoErro]++;

    fprintf(stderr, "linha %d: %s: ", linha, strErro[tipoErro]);

    // começa a ler a partir do que vem depois de fmt_msg
    va_start(args, fmt_msg);

    // imprimi fmt_msg substituindo os marcadores pelos argumentos listados em args
    vfprintf(stderr, fmt_msg, args);

    // encerra a leitura
    va_end(args);

    fprintf(stderr, "\n");
}

int totalErros() {
    return contagemErros[0] + contagemErros[1] + contagemErros[2];
}

int totalErroTipo(TipoErro tipoErro) {
    return contagemErros[tipoErro];
}
