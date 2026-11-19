#include <stdbool.h>
#include "semantica.h"
#include "erros.h"
#include "tipos.h"

bool verificarCondicaoBool(record *condicao, const char *construcao, int linha) {
    if (condicao == NULL || condicao->type == NULL)
        return false;

    if (condicao->type->categoria == T_ERRO)
        return true;

    CategoriaTipo tipoDaCondicao = condicao->type->categoria;
    bool expressaoAceita = tipoDaCondicao == T_BOOLEANO || tipoDaCondicao == T_INTEIRO;

    if (!expressaoAceita) {
        printErro(ERRO_SEMANTICO, linha, "condicao do '%s' deve ser booleana.", construcao);
        return false;
    }

    return expressaoAceita;
}
