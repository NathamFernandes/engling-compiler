%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"

    extern int yyerror (char *msg);
%}

%%

[ \t\n]                     ;

"tipo"                      { return TIPO; }
"constante"                 { return CONSTANTE; }
"funcao"                    { return FUNCAO; }
"procedimento"              { return PROCEDIMENTO; }
"novo"                      { return NOVO_TOK; }
"retorne"                   { return RETORNE_TOK; }

/* Tipos suportados pela linguagem (primitivos e estruturados) */
"inteiro"                   { return TIPO_INTEIRO; }
"caracter"                  { return TIPO_CARACTER; }
"flutuante"                 { return TIPO_FLUTUANTE; }
"decimal"                   { return TIPO_DECIMAL; }
"texto"                     { return TIPO_TEXTO; }
"booleano"                  { return TIPO_BOOLEANO; }

"vetor"                     { return TIPO_VETOR; }
"fila"                      { return TIPO_FILA; }
"pilha"                     { return TIPO_PILHA; }
"deque"                     { return TIPO_DEQUE; }
"hash"                      { return TIPO_HASH; }
"conjunto"                  { return CONJUNTO; }
"grafo"                     { return TIPO_GRAFO; }

/* Literais booleanos */
"Verdadeiro"                { yylval.iValue = 1; return LITERAL_BOOLEANO; }
"Falso"                     { yylval.iValue = 0; return LITERAL_BOOLEANO; }

/* Tokens de controle de fluxo */
"se"                        { return SE_TOK; }
"senao"                     { return SENAO_TOK; }
"para"                      { return PARA_TOK; }
"faca"                      { return FACA_TOK; }
"enquanto"                  { return ENQUANTO_TOK; }
"escolha"                   { return ESCOLHA_TOK; }
"caso"                      { return CASO_TOK; }
"pare"                      { return PARE_TOK; }
"padrao"                    { return PADRAO_TOK; }

"++"                        { return OPERADOR_INCREMENTO; }
"--"                        { return OPERADOR_DECREMENTO; }
"="                         { return OPERADOR_ATRIBUICAO; }
";"                         { return TERMINADOR; }

[0-9]+                      { yylval.iValue = atoi(yytext); return LITERAL_INTEIRO; }
[a-zA-Z][a-zA-Z0-9_]*       { yylval.sValue = strdup(yytext); return ID; }
.                           { yyerror("Caracter inválido"); }

%%

#ifndef yywrap
    int yywrap(void) { return 1; }
#endif
