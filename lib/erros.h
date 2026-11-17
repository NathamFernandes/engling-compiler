#ifndef ERROS_H
#define ERROS_H

typedef enum {
    ERRO_LEXICO,
    ERRO_SINTATICO,
    ERRO_SEMANTICO,
}
TipoErro;

void printErro(TipoErro tipoErro, int linha);
int totalErros();
int totalErroTipo(TipoErro tipoErro);

#endif
