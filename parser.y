%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
	char * sValue;  /* string value */
	};

%token <sValue> ID
%token CONST PONTO_E_VIRGULA TIPO_ESCALAR

%start programa

%%

programa : cabecalho {} ;

cabecalho : constantes {} ;

constantes : CONST declaracao PONTO_E_VIRGULA {}
            | CONST declaracao PONTO_E_VIRGULA constantes {} ;

declaracao : TIPO_ESCALAR ID {printf("Hello World!");} ;

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}