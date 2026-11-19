#include "helper.h"

static int matriz_coercao[TOTAL_TIPOS][TOTAL_TIPOS] = {l
    /* Casos padrão */
    [T_INTEIRO][T_INTEIRO]     = 1,
    [T_INTEIRO][T_FLUTUANTE]   = 1,
    [T_INTEIRO][T_DECIMAL]     = 1,
    [T_FLUTUANTE][T_FLUTUANTE] = 1,
    [T_FLUTUANTE][T_DECIMAL]   = 1,
    [T_DECIMAL][T_DECIMAL]     = 1,
    [T_CARACTER][T_CARACTER]   = 1,
    [T_TEXTO][T_TEXTO]         = 1,
    [T_BOOLEANO][T_BOOLEANO]   = 1,

    /* Casos especiais */
    
    // Flutuante    <- Inteiro
    [T_FLUTUANTE][T_INTEIRO]    = 1;

    // Decimal      <- Inteiro
    [T_DECIMAL][T_INTEIRO]      = 1;

    // Decimal      <- Flutuante
    [T_DECIMAL][T_FLUTUANTE]    = 1;

    // Texto        <- Caracter
    [T_TEXTO][T_CARACTER]       = 1;
};

char *validateType(const char *atrType, const char *exprType) {
    if (strcmp(atrType, "texto") == 0) {

    }
}