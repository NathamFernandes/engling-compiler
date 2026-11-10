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
	char	cValue;
	float	fValue;
	};

%token <sValue> ID LITERAL_TEXTO
%token <iValue> LITERAL_INTEIRO LITERAL_BOOLEANO
%token <cValue> LITERAL_CARACTER
%token <fValue> LITERAL_FLUTUANTE


/* ========================================================================== */
/*                         ESTRUTURAS E DECLARAÇÕES                           */
/* ========================================================================== */
%token TIPO         CONSTANTE     FUNCAO
%token PROCEDIMENTO RETORNE_TOK

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
%token PARA_TOK     FACA_TOK      ENQUANTO_TOK
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

/* Atribuição e Relacionais */
%token OPERADOR_ATRIBUICAO    MENOR         MAIOR

/* ========================================================================== */
/*                        DELIMITADORES E PONTUAÇÃO                           */
/* ========================================================================== */
%token VIRGULA      DOIS_PONTOS   TERMINADOR	PONTO

/* Escopo e Agrupamento */
%token A_PARENTESE  F_PARENTESE
%token A_CHAVE      F_CHAVE
%token A_COLCHETE   F_COLCHETE


%start programa

%%

programa	: cabecalho subprogramas instrucoes {}
			;

cabecalho	: constantes tipoUsuario	{} 
			; 

constantes	: 											{}
			| constantes declaracaoConstante TERMINADOR	{} 
			; 

declaracaoConstante	: CONSTANTE tipo ID OPERADOR_ATRIBUICAO expressao {}
					;

tipoUsuario	: 											{}
			| tipoUsuario novoTipoUsuario TERMINADOR 	{}
			;

novoTipoUsuario	: TIPO A_CHAVE tipoUsuarioDeclaracoes F_CHAVE ID {}
				;

tipoUsuarioDeclaracoes	: declaracao TERMINADOR 
						| declaracao TERMINADOR tipoUsuarioDeclaracoes	{}
						;

subprogramas	: 										{}
				| subprogramas subprograma TERMINADOR 	{}
				;

subprograma		: funcao | procedimento {}
				;

funcao			: FUNCAO tipo ID A_PARENTESE parametros F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
				;

procedimento	: PROCEDIMENTO ID A_PARENTESE parametros F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
				;

parametros		:											{}
				| tipo ID 									{}
				| tipo ID VIRGULA parametros				{}
				;

parametrosChamada			:								{}
							| ID							{}
							| ID VIRGULA parametrosChamada	{}
							;

instrucoes	: 
			| instrucao TERMINADOR instrucoes	{} 
			;

instrucao 	: declaracao			{} 
			| atribuicao 			{}
			| condicionalSe			{}
			| condicionalCaso		{}
			| lacoPara				{}
			| lacoEnquanto			{}
			| chamadaSubprograma	{}
			| controle				{}
			| retorno				{}
			;

atribuicao 			: atribuicaoComDeclaracao		{}
					| atribuicaoSemDeclaracao		{}
					;

atribuicaoComDeclaracao	: declaracao OPERADOR_ATRIBUICAO expressao 	{}
						;

variavel		: ID				{}	
				| variavel PONTO ID {}
				;

atribuicaoSemDeclaracao	: variavel OPERADOR_ATRIBUICAO expressao 			{}
						| cremento											{}
						;

cremento			: variavel OPERADOR_INCREMENTO						{}
					| variavel OPERADOR_DECREMENTO						{}
					;

declaracao 			: tipo ID	 									{} 
					;

condicionalSe		: SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE listaSenaoSe senaoOpcional {} 
					;

listaSenaoSe		: 																							{}
    				| listaSenaoSe SENAO_SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE 	{}
    				;

senaoOpcional		: 										{}
    				| SENAO_TOK A_CHAVE instrucoes F_CHAVE	{}
    				;

condicionalCaso		: ESCOLHA_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE listaCasos PADRAO_TOK DOIS_PONTOS instrucoes F_CHAVE {} ;

listaCasos			: 														{}
					| listaCasos CASO_TOK expressao DOIS_PONTOS instrucoes	{} 
					;

lacoPara			: PARA_TOK A_PARENTESE atribuicaoComDeclaracao TERMINADOR expressao TERMINADOR atribuicaoSemDeclaracao F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
					;

lacoEnquanto		: ENQUANTO_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
					;

chamadaSubprograma	: ID A_PARENTESE parametrosChamada F_PARENTESE {}
					;

controle			: PARE_TOK 		{} 
					| CONTINUE_TOK	{}
					;

retorno				: RETORNE_TOK ID {}
					;

expressao 			: LITERAL_INTEIRO 								{}
					| LITERAL_FLUTUANTE 							{}
					| LITERAL_CARACTER 								{}
					| LITERAL_TEXTO 								{}
					| LITERAL_BOOLEANO 								{} 
					| ID sufixoId									{}
					| chamadaSubprograma							{}
					;

sufixoId			: 
					| sufixoId A_COLCHETE expressao F_COLCHETE 		{}
					;

tipo 				: tipoEscalar
					| tipoDimensional								{} 
					| ID											{}
					;

tipoEscalar 		: TIPO_INTEIRO  								{}
					| TIPO_CARACTER  								{}
					| TIPO_FLUTUANTE  								{}
					| TIPO_DECIMAL  								{}
					| TIPO_TEXTO  									{}
					| TIPO_BOOLEANO 								{} 
					;

tipoDimensional		: TIPO_VETOR MENOR tipo MAIOR					{}
					;

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}
