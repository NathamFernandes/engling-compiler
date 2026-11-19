#ifndef SEMANTICA_H
#define SEMANTICA_H

#include <stdbool.h>
#include <stdlib.h>
#include "record.h"
#include "tipos.h"
#include "erros.h"

/* ========================================================================== */
/*                            Condicional                                     */
/* ========================================================================== */
bool verificarCondicaoBool(record *condicao, const char* construcao, int linha);

#endif
