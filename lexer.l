%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"

    extern int yyerror (char *msg);
%}

%option noyywrap
%option yylineno

DIGITO      [0-9]
CARACTER    [a-zA-Z_]
ID          {CARACTER}({CARACTER}|{DIGITO})*

%%

"//".*                      ;
"/*"([^*]|\*+[^*/])*\*+"/"  ;
[ \t\r\n]+                  ;

"tipo"                      { return TIPO; }
"constante"                 { return CONSTANTE; }
"funcao"                    { return FUNCAO; }
"procedimento"              { return PROCEDIMENTO; }
"retorne"                   { return RETORNE_TOK; }
"novo"                      { return NOVO; }
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

"{"                         { return A_CHAVE; }
"}"                         { return F_CHAVE; }
"("                         { return A_PARENTESE; }
")"                         { return F_PARENTESE; }
"["                         { return A_COLCHETE; }
"]"                         { return F_COLCHETE; }

"++"                        { return OPERADOR_INCREMENTO; }
"--"                        { return OPERADOR_DECREMENTO; }
"+"                         { return OPERADOR_SOMA; }
"-"                         { return OPERADOR_SUBTRACAO; }
"*"                         { return OPERADOR_MULTIPLICACAO; }
"/"                         { return OPERADOR_DIVISAO; }
"%"                         { return OPERADOR_MODULO; }
"^"                         { return OPERADOR_EXPONENCIACAO; }
"#"                         { return OPERADOR_TAMANHO; }

"||"                        { return OPERADOR_OU; }
"&&"                        { return OPERADOR_E; }
"!"                         { return OPERADOR_NEGACAO; }

"=="                        { return OPERADOR_IGUAL; }
"!="                        { return OPERADOR_DIFERENTE; }
"<="                        { return OPERADOR_MENOR_IGUAL; }
">="                        { return OPERADOR_MAIOR_IGUAL; }
"="                         { return OPERADOR_ATRIBUICAO; }

"<"                         { return MENOR; }
">"                         { return MAIOR; }

","                         { return VIRGULA; }
":"                         { return DOIS_PONTOS; }
";"                         { return TERMINADOR; }
"."                         { return PONTO; }

{DIGITO}+                   { yylval.iValue = atoi(yytext); return LITERAL_INTEIRO; }
{DIGITO}+"."{DIGITO}+       { yylval.fValue = atof(yytext); return LITERAL_FLUTUANTE; }
\'([^'\\\n]|\\.)\'          { yylval.cValue = (yytext[1] == '\\' ? yytext[2] : yytext[1]); return LITERAL_CARACTER; }
\"([^"\\\n]|\\.)*\"         { yylval.sValue = strdup(yytext); return LITERAL_TEXTO; }
{ID}                        { yylval.sValue = strdup(yytext); return ID; }

.                           { yyerror("Caracter inválido"); }

%%