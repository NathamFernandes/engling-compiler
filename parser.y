%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pilha.h"
#include "hash_table.h"
#include "record.h"

pilha *pilha_escopos;
HashTable *ht;

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

char * cat(char *, char *, char *, char *, char *);

%}

%union {
    int     iValue;
    char *  sValue;
    char    cValue;
    float   fValue;
};

%token <sValue> ID LITERAL_TEXTO
%token <iValue> LITERAL_INTEIRO LITERAL_BOOLEANO
%token <cValue> LITERAL_CARACTER
%token <fValue> LITERAL_FLUTUANTE
%type <sValue> tipo tipoCast tipoEscalar cabecalho subprogramas instrucoes constantes declaracaoConstante expressao


/* ========================================================================== */
/*                         ESTRUTURAS E DECLARAÇÕES                           */
/* ========================================================================== */
%token TIPO         CONSTANTE     FUNCAO
%token PROCEDIMENTO RETORNE_TOK NOVO

/* ========================================================================== */
/*                               TIPOS DE DADOS                               */
/* ========================================================================== */
/* Tipos Primitivos */
%token TIPO_INTEIRO TIPO_CARACTER TIPO_FLUTUANTE
%token TIPO_DECIMAL TIPO_TEXTO    TIPO_BOOLEANO

/* Tipos Estruturados */
%token TIPO_VETOR   TIPO_FILA     TIPO_PILHA
%token TIPO_DEQUE   TIPO_CONJUNTO TIPO_GRAFO

/* ========================================================================== */
/*                            CONTROLE DE FLUXO                               */
/* ========================================================================== */
%token SE_TOK       SENAO_TOK     SENAO_SE_TOK
%token PARA_TOK     ENQUANTO_TOK  FACA_TOK
%token ESCOLHA_TOK  CASO_TOK      PARE_TOK
%token CONTINUE_TOK PADRAO_TOK

/* ========================================================================== */
/*                                OPERADORES                                  */
/* ========================================================================== */
/* Aritméticos e Especiais */
%token OPERADOR_INCREMENTO    OPERADOR_DECREMENTO
%token OPERADOR_SOMA          OPERADOR_SUBTRACAO
%token OPERADOR_MULTIPLICACAO OPERADOR_DIVISAO
%token OPERADOR_MODULO        OPERADOR_EXPONENCIACAO
%token OPERADOR_TAMANHO

/* Lógicos */
%token OPERADOR_OU            OPERADOR_E                  OPERADOR_NEGACAO

/* Relacionais e Atribuição */
%token OPERADOR_ATRIBUICAO    MENOR                       MAIOR
%token OPERADOR_IGUAL         OPERADOR_DIFERENTE
%token OPERADOR_MENOR_IGUAL   OPERADOR_MAIOR_IGUAL

/* ========================================================================== */
/*                        DELIMITADORES E PONTUAÇÃO                           */
/* ========================================================================== */
%token VIRGULA      DOIS_PONTOS   TERMINADOR    PONTO

/* Escopo e Agrupamento */
%token A_PARENTESE  F_PARENTESE
%token A_CHAVE      F_CHAVE
%token A_COLCHETE   F_COLCHETE


%start programa

%%

programa    : cabecalho subprogramas instrucoes { printf("%s;", $1); }
            ;

cabecalho   : constantes tipoUsuario    { $$ = "aaaa"; } 
            ; 

constantes  : | constantes declaracaoConstante TERMINADOR { $$ = $2; } 
            ; 

declaracaoConstante : CONSTANTE tipo ID OPERADOR_ATRIBUICAO expressao { 
                        if ($2 != NULL && strcmp($2, "inteiro") == 0) {
                            if (!inserir_linha(ht, pilha_escopos, $3, $2, CAT_CONSTANTE, yylineno)) {
                                fprintf(stderr, "Erro semantico (linha %d): constante '%s' ja declarada.\n", yylineno, $3);
                            } else {
                                printf("Constante inteira '%s' inserida com sucesso!\n", $3);
                                $$ = cat("const int ", $3, " = ", "meu teste", "");
                            }
                        }
                    }
                    ;

tipoUsuario :                                           {}
            | tipoUsuario novoTipoUsuario TERMINADOR    {}
            ;

novoTipoUsuario : TIPO A_CHAVE tipoUsuarioDeclaracoes F_CHAVE ID {}
                ;

tipoUsuarioDeclaracoes  : declaracao TERMINADOR 
                        | declaracao TERMINADOR tipoUsuarioDeclaracoes  {}
                        ;

subprogramas    :                                       {}
                | subprogramas subprograma TERMINADOR   {}
                ;

subprograma     : funcao | procedimento {}
                ;

funcao          : FUNCAO tipo ID A_PARENTESE parametros F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
                ;

procedimento    : PROCEDIMENTO ID A_PARENTESE parametros F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
                ;

parametros      :                                           {}
                | tipo ID                                   {}
                | tipo ID VIRGULA parametros                {}
                ;

parametrosChamada           :                               {}
                            | expressao                         {}
                            | expressao VIRGULA parametrosChamada   {}
                            ;

instrucoes  : 
            | instrucao TERMINADOR instrucoes   {} 
            ;

instrucao   : declaracao            {} 
            | atribuicao            {}
            | condicionalSe         {}
            | condicionalCaso       {}
            | lacoPara              {}
            | lacoEnquanto          {}
            | chamadaSubprograma    {}
            | controle              {}
            | retorno               {}
            ;

atribuicao          : atribuicaoComDeclaracao       {}
                    | atribuicaoSemDeclaracao       {}
                    ;

atribuicaoComDeclaracao : declaracao OPERADOR_ATRIBUICAO expressao  {}
                        ;

variavel
    : ID                                            {}  
    | variavel PONTO ID                             {}
    | variavel A_COLCHETE expressao F_COLCHETE      {}
    ;

atribuicaoSemDeclaracao : variavel OPERADOR_ATRIBUICAO expressao            {}
                        | cremento                                          {}
                        ;

cremento            : variavel OPERADOR_INCREMENTO                      {}
                    | variavel OPERADOR_DECREMENTO                      {}
                    ;

declaracao          : tipo ID                                       {} 
                    ;

condicionalSe       : SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE listaSenaoSe senaoOpcional {} 
                    ;

listaSenaoSe        :                                                                                           {}
                    | listaSenaoSe SENAO_SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE    {}
                    ;

senaoOpcional       :                                       {}
                    | SENAO_TOK A_CHAVE instrucoes F_CHAVE  {}
                    ;

condicionalCaso     : ESCOLHA_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE listaCasos PADRAO_TOK DOIS_PONTOS instrucoes F_CHAVE {} ;

listaCasos          :                                                       {}
                    | listaCasos CASO_TOK expressao DOIS_PONTOS instrucoes  {} 
                    ;

lacoPara            : PARA_TOK A_PARENTESE atribuicaoComDeclaracao TERMINADOR expressao TERMINADOR atribuicaoSemDeclaracao F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
                    ;

lacoEnquanto        : ENQUANTO_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
                    ;

chamadaSubprograma  : ID A_PARENTESE parametrosChamada F_PARENTESE {}
                    ;

controle            : PARE_TOK      {} 
                    | CONTINUE_TOK  {}
                    ;

retorno             : RETORNE_TOK expressao {}
                    ;

/* PARTE QUE TA DANDO CONFLITO, PROVAVELMENTE */

expressao   : expressaoLogicaE                            {}
    | expressao OPERADOR_OU expressaoLogicaE            {}
    ;
    
expressaoLogicaE
    : expressaoRelacional                           {}
    | expressaoLogicaE OPERADOR_E expressaoRelacional {}
    ;

expressaoRelacional
    : expressaoAditiva                              {}
    | expressaoAditiva operadorRelacional expressaoAditiva {}
    ;

operadorRelacional
    : OPERADOR_IGUAL                                {}
    | OPERADOR_DIFERENTE                            {}
    | MENOR                                         {}
    | OPERADOR_MENOR_IGUAL                          {}
    | MAIOR                                         {}
    | OPERADOR_MAIOR_IGUAL                          {}
    ;

expressaoAditiva
    : expressaoMultiplicativa                       {}
    | expressaoAditiva OPERADOR_SOMA expressaoMultiplicativa      {}
    | expressaoAditiva OPERADOR_SUBTRACAO expressaoMultiplicativa {}
    ;

expressaoMultiplicativa
    : expressaoExponencial                          {}
    | expressaoMultiplicativa OPERADOR_MULTIPLICACAO expressaoExponencial {}
    | expressaoMultiplicativa OPERADOR_DIVISAO expressaoExponencial       {}
    | expressaoMultiplicativa OPERADOR_MODULO expressaoExponencial        {}
    ;

expressaoExponencial
    : expressaoUnaria                               {}
    | expressaoUnaria OPERADOR_EXPONENCIACAO expressaoExponencial {}
    ;

expressaoUnaria
    : expressaoPosfixa                                  {}
    | operadorUnario expressaoUnaria                    {}
    | A_PARENTESE tipoCast F_PARENTESE expressaoUnaria  {}
    ;

operadorUnario
    : OPERADOR_SUBTRACAO                            {}
    | OPERADOR_NEGACAO                              {}
    | OPERADOR_TAMANHO                              {}
    ;

expressaoPosfixa
    : termo                                         {}
    | termo OPERADOR_INCREMENTO                     {}
    | termo OPERADOR_DECREMENTO                     {}
    ;

termo
    : ID                                            {}
    | ID sufixoId                                   {}
    | LITERAL_INTEIRO                               {}
    | LITERAL_FLUTUANTE                             {}
    | LITERAL_CARACTER                              {}
    | LITERAL_TEXTO                                 {}
    | LITERAL_BOOLEANO                              {}
    | A_PARENTESE expressao F_PARENTESE             {}
    | NOVO tipo A_PARENTESE listaExpressoesOpcional F_PARENTESE {}
    ;

sufixoId
    : listaIndexacao                                {}
    | A_PARENTESE listaExpressoesOpcional F_PARENTESE {}
    ;

listaIndexacao
    : A_COLCHETE expressao F_COLCHETE               {}
    | listaIndexacao A_COLCHETE expressao F_COLCHETE {}
    ;

listaExpressoesOpcional
    :                                               {}
    | listaExpressoes                               {}
    ;

listaExpressoes
    : expressao                                     {}
    | listaExpressoes VIRGULA expressao             {}
    ;

tipoCast            : tipoEscalar                   { $$ = $1; }
                    | tipoDimensional               { $$ = NULL; }
                    ;

tipo                : tipoCast                      { $$ = $1; }
                    | ID                            { $$ = $1; }
                    ;

tipoEscalar         : TIPO_INTEIRO                  { $$ = strdup("inteiro"); }
                    | TIPO_CARACTER                 { $$ = NULL; }
                    | TIPO_FLUTUANTE                { $$ = NULL; }
                    | TIPO_DECIMAL                  { $$ = NULL; }
                    | TIPO_TEXTO                    { $$ = NULL; }
                    | TIPO_BOOLEANO                 { $$ = NULL; }
                    | TIPO_FILA                     { $$ = NULL; }
                    | TIPO_PILHA                    { $$ = NULL; }
                    | TIPO_DEQUE                    { $$ = NULL; }
                    | TIPO_CONJUNTO                 { $$ = NULL; }
                    | TIPO_GRAFO                    { $$ = NULL; }
                    ;

tipoDimensional     : TIPO_VETOR MENOR tipo MAIOR   {}
                    ;


/* FIM DA PARTE QUE TA DANDO CONFLITO, PROVAVELMENTE */

%%

int main (void) {
    pilha_escopos = criar_pilha();
    push(pilha_escopos, "global");
    ht = criar_tabela();

    int res = yyparse();

    liberar_tabela(ht);
    liberar_pilha(pilha_escopos);
    return res;
}

int yyerror (char *msg) {
    fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
    return 0;
}

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5){
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}