%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"

    extern int yyerror (char *msg);
%}

/* Macros/Defines/Variáveis do lex ???? */

DIGITO      [0-9]
CARACTER    [a-zA-Z_]
ID          {CARACTER}({CARACTER}|{DIGITO})*

%%

"//".*                      ;
"/*"([^*]|\*+[^*/])*\*+"/"  ;
[ \t\r\n]                   ;

"tipo"                      { return TIPO; }
"constante"                 { return CONSTANTE; }
"funcao"                    { return FUNCAO; }
"procedimento"              { return PROCEDIMENTO; }
"retorne"                   { return RETORNE_TOK; }

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
"conjunto"                  { return TIPO_CONJUNTO; }
"grafo"                     { return TIPO_GRAFO; }

"{"                         { return A_CHAVE; }
"}"                         { return F_CHAVE; }
"("                         { return A_PARENTESE; }
")"                         { return F_PARENTESE; }
"["                         { return A_COLCHETE; }
"]"                         { return F_COLCHETE; }
"<"                         { return MENOR; }
">"                         { return MAIOR; }

"Verdadeiro"                { yylval.iValue = 1; return LITERAL_BOOLEANO; }
"Falso"                     { yylval.iValue = 0; return LITERAL_BOOLEANO; }

"se"                        { return SE_TOK; }
"senao"                     { return SENAO_TOK; }
"senaose"                   { return SENAO_SE_TOK; }
"para"                      { return PARA_TOK; }
"faca"                      { return FACA_TOK; }
"enquanto"                  { return ENQUANTO_TOK; }
"escolha"                   { return ESCOLHA_TOK; }
"caso"                      { return CASO_TOK; }
"pare"                      { return PARE_TOK; }
"continue"                  { return CONTINUE_TOK; }
"padrao"                    { return PADRAO_TOK; }

/* Operadores Aritméticos */
"++"                        { return OPERADOR_INCREMENTO; }
"--"                        { return OPERADOR_DECREMENTO; }
"+"                         { return OPERADOR_SOMA; }
"-"                         { return OPERADOR_SUBTRACAO; }
"*"                         { return OPERADOR_MULTIPLICACAO; }
"/"                         { return OPERADOR_DIVISAO; }
"%"                         { return OPERADOR_MODULO; }
"^"                         { return OPERADOR_EXPONENCIACAO; }
"#"                         { return OPERADOR_CERQUILHA; } /* Serve para retornar a quantidade de elementos de uma coleção */
"="                         { return OPERADOR_ATRIBUICAO; }
","                         { return VIRGULA; }
":"                         { return DOIS_PONTOS; }
";"                         { return TERMINADOR; }

/* Delimitadores e pontuação */
"("                         { return PARENTESE_ESQ; }
")"                         { return PARENTESE_DIR; }
"{"                         { return CHAVE_ESQ; }
"}"                         { return CHAVE_DIR; }
"["                         { return COLCHETE_ESQ; }
"]"                         { return COLCHETE_DIR; }
";"                         { return PONTO_VIRGULA; }
":"                         { return DOIS_PONTOS; }
","                         { return VIRGULA; }

{DIGITO}+                   { yylval.iValue = atoi(yytext); return LITERAL_INTEIRO; } /* Reconhecimento de inteiros             */
{DIGITO}+"."{DIGITO}+       { yylval.fValue = atof(yytext); return LITERAL_FLOAT; }   /* Reconhecimento de pontos flutuantes    */
\'([^\']\\.)\'              { yylval.cValue = yytext[1]; return LITERAL_CHAR; }       /* Reconhecimento de caracter             */
\"([^\"\\]\\.)*\"           { yylval.sValue = strdup(yytext); return LITERAL_TEXTO; } /* Reconhecimento de strings              */
{ID}                        { yylval.sValue = strdup(yytext); return ID; }            /* Reconhecimento de variável             */
/* [a-zA-Z][a-zA-Z0-9_]*       { yylval.sValue = strdup(yytext); return ID; }            /* Reconhecimento de variável             */

.                           { yyerror("Caracter inválido"); }                         /* Tratamento de erro léxico              */

%%

#ifndef yywrap
    int yywrap(void) { return 1; }
#endif
