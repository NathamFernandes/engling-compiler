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
%token CONSTANTE TIPO A_CHAVE F_CHAVE A_PARENTESE F_PARENTESE A_COLCHETE F_COLCHETE TIPO_INTEIRO TIPO_CARACTER TIPO_FLUTUANTE TIPO_DECIMAL TIPO_TEXTO TIPO_BOOLEANO OPERADOR_INCREMENTO OPERADOR_DECREMENTO OPERADOR_ATRIBUICAO TERMINADOR

%start programa

%%

programa	: cabecalho 			{} 
			;

cabecalho	: constantes tipoUsuario	{} 
			; 

constantes	: declaracaoConstante TERMINADOR				{} 
			| declaracaoConstante TERMINADOR constantes		{} 
			; 

declaracaoConstante	: CONSTANTE tipo ID OPERADOR_ATRIBUICAO expressao {}
					;

tipoUsuario	: novoTipoUsuario TERMINADOR | novoTipoUsuario TERMINADOR tipoUsuario{}
			;

novoTipoUsuario	: TIPO A_CHAVE tipoUsuarioDeclaracoes F_CHAVE ID {}
				;

tipoUsuarioDeclaracoes	: declaracao TERMINADOR | declaracao TERMINADOR tipoUsuarioDeclaracoes	{}
						;

instrucoes	: instrucao TERMINADOR 							{}
			| instrucao TERMINADOR instrucoes 				{} 
			;

instrucao 	: declaracao	 								{} 
			| atribuicao 									{} 
			;

atribuicao 			: declaracao OPERADOR_ATRIBUICAO expressao 		{}
					| ID OPERADOR_ATRIBUICAO expressao 				{}
					| ID OPERADOR_INCREMENTO						{}
					| ID OPERADOR_DECREMENTO 						{}
					;

declaracao 			: tipo ID	 									{} 
					;

expressao 			: LITERAL_INTEIRO	 							{} 
					;

tipo 				: tipoEscalar 									{} 
					;

tipoEscalar 		: TIPO_INTEIRO  								{}
					| TIPO_CARACTER  								{}
					| TIPO_FLUTUANTE  								{}
					| TIPO_DECIMAL  								{}
					| TIPO_TEXTO  									{}
					| TIPO_BOOLEANO 								{} 
					;

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}