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
	int 	iValue;
	char * 	sValue;
	};

%token <sValue> ID
%token <iValue> LITERAL_INTEIRO
%token CONSTANTE TIPO_INTEIRO TIPO_CARACTER TIPO_FLUTUANTE TIPO_DECIMAL TIPO_TEXTO TIPO_BOOLEANO OPERADOR_ATRIBUICAO TERMINADOR

%start programa

%%

programa : cabecalho instrucoes {} ;

cabecalho : | constantes {} ; 
constantes : constante TERMINADOR | constante TERMINADOR constantes {} ; 

constante : CONSTANTE declaracao | CONSTANTE atribuicao {} ;

instrucoes : instrucao TERMINADOR | instrucao TERMINADOR instrucoes {} ;

instrucao : declaracao | atribuicao {} ;

declaracao : tipo ID { printf("Hello!"); }
atribuicao : tipo ID OPERADOR_ATRIBUICAO LITERAL_INTEIRO { printf("Hello World!"); }

tipo : tipoEscalar {} ;

tipoEscalar : TIPO_INTEIRO | TIPO_CARACTER | TIPO_FLUTUANTE | TIPO_DECIMAL | TIPO_TEXTO | TIPO_BOOLEANO {} ;

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}