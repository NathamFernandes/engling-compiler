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

"inteiro"                   { return TIPO_INTEIRO; }
"caracter"                  { return TIPO_CARACTER; }
"flutuante"                 { return TIPO_FLUTUANTE; }
"decimal"                   { return TIPO_DECIMAL; }
"texto"                     { return TIPO_TEXTO; }
"booleano"                  { return TIPO_BOOLEANO; }

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