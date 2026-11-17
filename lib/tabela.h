#ifndef TABELA_H
#define TABELA_H

/* ========================================================================== */
/*                          MODELAGEM DE TIPOS                                */
/* ========================================================================== */

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
} 
CategoriaTipo;

typedef struct Tipo Tipo;
typedef struct Atributo Atributo;


/* serve para representar cada atributo (ou membro) declarado dentro de um tipo definido pelo usuário 
 *
 * Ex:
 *    
 *    TIPO {
 *       texto nome;
 *       inteiro idade;
 *   } Aluno;
 *
 *   char *id           -> Guarda o identificador do atributo. No exemplo acima, id = nome.
 *   Tipo *tipo         -> Aponta para o tipo do atributo. No exemplo cima, inteiro.
 *   Atributo *proximo  -> Aponta para o proximo atributo dentro da struct definida pelo usuário.
 *              
 *              Ex: Nó 1 - id = nome, tipo = T_TEXTO, proximo = Nó 2
 *                  Nó 2 - id = idade, tipo = T_INTEIRO, proximo = NULL
*/
struct Atributo {
    char *id;
    Tipo *tipo;
    Atributo *proximoAtributo;
};

struct Tipo {
    CategoriaTipo categoria;
    char *nomeTipo;
};


/* ========================================================================== */
/*                        MODELAGEM DE SÍMBOLOS E TABELA                      */
/* ========================================================================== */

typedef enum { 
    SIM_VARIAVEL,
    SIM_CONSTANTE,
    SIM_TIPO,
    SIM_FUNCAO,
    SIM_PROCEDIMENTO,
} CategoriaSimbolo;

typedef struct Parametro Parametro;
typedef struct Simbolo Simbolo;
typedef struct TabelaSimbolo TabelaSimbolo;

/* Lista de parametros utilizados em funções ou procedimentos. Segue a mesma logica da struct de atributos. */
struct Parametro {
    char *id;
    Tipo *tipo;
    Parametro *proximoParametro;
};

/* Entrada individual de um simbolo na tabela de simbolo */
struct Simbolo {
    char *nome;
    CategoriaSimbolo categoria;
    Tipo *tipo;
    int linhaDeclaração;            // Guarda o valor de yylineno para exibir mensagens de erro
    Parametro *parametros;          // Lista de parâmetros (se SIM_FUNCAO ou SIM_PROCEDIMENTO)
    Simbolo *proximoSimbolo;        // Ponteiro para o proximo simbolo
};


struct TabelaSimbol {
    Simbolo *primeiroSimbolo;
}; 


/* ========================================================================== */
/*                         PROTÓTIPOS DAS FUNÇÕES (API)                       */
/* ========================================================================== */

#endif
