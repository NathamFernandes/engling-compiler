%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pilha.h"
#include "hash_table.h"
#include "record.h"
#include "erros.h"
#include "tipos.h"
#include "semantica.h"


pilha *pilha_escopos;
HashTable *hash_table;

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

extern FILE *yyin;
FILE *arquivo_saida = NULL;

char * cat(char *, char *, char *, char *, char *);

%}

%union {
    int             iValue;
    char            *sValue;
    char            cValue;
    float           fValue;
    struct record   *rec; 
};

%token <sValue> ID LITERAL_TEXTO
%token <iValue> LITERAL_INTEIRO LITERAL_BOOLEANO
%token <cValue> LITERAL_CARACTER
%token <fValue> LITERAL_FLUTUANTE

%type <rec> cabecalho subprogramas instrucoes
%type <rec> constantes declaracaoConstante tipoUsuario
%type <rec> tipo tipoCast tipoEscalar tipoDimensional
%type <rec> expressao expressaoLogicaE expressaoRelacional expressaoAditiva
%type <rec> expressaoMultiplicativa expressaoExponencial expressaoUnaria
%type <rec> expressaoPosfixa termo sufixoId listaIndexacao
%type <rec> listaExpressoesOpcional listaExpressoes

%type <sValue> operadorRelacional operadorUnario

%type <rec> instrucao condicionalSe listaSenaoSe senaoOpcional


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

programa    : cabecalho subprogramas instrucoes { 
                if (totalErros() == 0) {
                    char *codigo_final = cat($1->code, "\n", $2->code, "\n", $3->code);

                    if (arquivo_saida != NULL) {
                        fprintf(arquivo_saida, "%s\n", codigo_final);
                    } else {
                        printf("%s\n", codigo_final);
                    }

                    free(codigo_final);
                } else {
                    printf("Compilação abortada com %d erros(s).\n", totalErros());
                }

                freeRecord($1);
                freeRecord($2);
                freeRecord($3);
            }
            ;

cabecalho   : constantes tipoUsuario    {
                char *code = cat($1->code, "\n", $2->code, "", "");
                freeRecord($1);
                freeRecord($2);
                $$ = createRecord(strdup(code), NULL);
                free(code);
            } 
            ; 

constantes  :                                           { $$ = createRecord(strdup(""), NULL); }  
            | constantes declaracaoConstante TERMINADOR { 
                char *code = cat($1->code, "\n", $2->code, ";\n", "");
                freeRecord($1);
                freeRecord($2);
                $$ = createRecord(strdup(code), NULL);    
                free(code);
            }   
            ; 

declaracaoConstante : CONSTANTE tipo ID OPERADOR_ATRIBUICAO expressao { 
                        $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));
                        simbolo *sym = buscar_simbolo(hash_table, pilha_escopos, $3);

                        if (sym != NULL) {
                            printErro(ERRO_SEMANTICO, yylineno, "constante '%s' já declarada na linha %d.", $3, sym->linha_declaracao);
                            goto fim_declaracaoConstante;
                        }

                        if (!tipos_compativeis($2->type, $5->type)) {
                            printErro(ERRO_SEMANTICO, yylineno, "tipo incompativel na declaração da constante '%s'.", $3);
                            goto fim_declaracaoConstante;
                        }

                        inserir_simbolo(hash_table, pilha_escopos, $3, $2->type, CAT_CONSTANTE, yylineno);
                        free($$->code);
                        liberar_tipo($$->type);

                        char *temp = cat("const ", $2->code, " ", $3, " = ");
                        $$->code = cat(temp, $5->code, "", "", "");
                        $$->type = clonar_tipo($2->type);

                        free(temp);

                    fim_declaracaoConstante:
                        freeRecord($2);
                        freeRecord($5);
                        free($3);
                    }
                    ;

tipoUsuario :                                           { $$ = createRecord(strdup(""), NULL); }
            | tipoUsuario novoTipoUsuario TERMINADOR    { $$ = createRecord(strdup(""), NULL); }
            ;

novoTipoUsuario : TIPO A_CHAVE tipoUsuarioDeclaracoes F_CHAVE ID {}
                ;

tipoUsuarioDeclaracoes  : declaracao TERMINADOR 
                        | declaracao TERMINADOR tipoUsuarioDeclaracoes  {}
                        ;

subprogramas    :                                       { $$ = createRecord(strdup(""), NULL); }
                | subprogramas subprograma TERMINADOR   { $$ = createRecord(strdup(""), NULL); }
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

instrucoes  :                                   { $$ = createRecord(strdup(""), NULL); }
            | instrucao TERMINADOR instrucoes   { $$ = createRecord(cat($1->code, ";\n", $3->code, "", ""), NULL); freeRecord($1); freeRecord($3); } 
            ;

instrucao   : declaracao            { $$ = createRecord(strdup(""), NULL); } 
            | atribuicao            { $$ = createRecord(strdup(""), NULL); }
            | condicionalSe         { $$ = $1; }
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

condicionalSe       : SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE { push(pilha_escopos, "bloco_se"); } instrucoes { pop(pilha_escopos); } F_CHAVE listaSenaoSe senaoOpcional {
                            verificarCondicaoBool($3, "se", yylineno);

                            char *instrucaoIf = cat("if (", $3->code, ") {\n", $7->code, "}");

                            $$ = createRecord(cat(instrucaoIf, "", $10->code, $11->code, ""), NULL);

                            free(instrucaoIf);
                            freeRecord($3);
                            freeRecord($7);
                            freeRecord($10);
                            freeRecord($11);
                    } 
                    ;

listaSenaoSe        :                                                                                           { $$ = createRecord(strdup(""), NULL); }
                    | listaSenaoSe SENAO_SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE instrucoes F_CHAVE    {
                        verificarCondicaoBool($4, "senaose", yylineno);

                        char *instrucaoSenaoSe = cat(" else if (", $4->code, ") {\n", $7->code, "}");

                        $$ = createRecord(cat($1->code, instrucaoSenaoSe, "", "", ""), NULL);

                        free(instrucaoSenaoSe);
                        freeRecord($1);
                        freeRecord($4);
                        freeRecord($7);
                    }
                    ;

senaoOpcional       :                                       { $$ = createRecord(strdup(""), NULL); }
                    | SENAO_TOK A_CHAVE instrucoes F_CHAVE  {
                        char *instrucaoSenao = cat(" senao {\n", $3->code, "}", "", "");

                        $$ = createRecord(instrucaoSenao, NULL);

                        free(instrucaoSenao);
                        freeRecord($3);
                    }
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
expressao
    : expressaoLogicaE                                      { $$ = $1; }
    | expressao OPERADOR_OU expressaoLogicaE                { $$ = NULL; }
    ;
    
expressaoLogicaE
    : expressaoRelacional                                   { $$ = $1; }
    | expressaoLogicaE OPERADOR_E expressaoRelacional       { $$ = NULL; }
    ;

expressaoRelacional
    : expressaoAditiva                                      { $$ = $1; }
    | expressaoAditiva operadorRelacional expressaoAditiva  { 
        int expressaoValida = tipos_compativeis($1->type, $3->type) && tipos_compativeis($3->type, $1->type) != 0;

        if (!expressaoValida) {
            printErro(ERRO_SEMANTICO, yylineno, "operandos incompativeis na comparacao.");
        }

        $$ = createRecord(cat($1->code, " ", $2, " ", $3->code), criar_tipo(T_BOOLEANO, NULL, NULL));

        free($2);
        freeRecord($1);
        freeRecord($3);
}
    ;

operadorRelacional
    : OPERADOR_IGUAL                                        { $$ = strdup("="); }
    | OPERADOR_DIFERENTE                                    { $$ = strdup("!<"); }
    | MENOR                                                 { $$ = strdup("<"); }
    | OPERADOR_MENOR_IGUAL                                  { $$ = strdup("<="); }
    | MAIOR                                                 { $$ = strdup(">"); }
    | OPERADOR_MAIOR_IGUAL                                  { $$ = strdup(">="); }
    ;

expressaoAditiva
    : expressaoMultiplicativa                               { $$ = $1; }
    | expressaoAditiva OPERADOR_SOMA expressaoMultiplicativa      { $$ = NULL; }
    | expressaoAditiva OPERADOR_SUBTRACAO expressaoMultiplicativa { $$ = NULL; }
    ;

expressaoMultiplicativa
    : expressaoExponencial                                  { $$ = $1; }
    | expressaoMultiplicativa OPERADOR_MULTIPLICACAO expressaoExponencial { $$ = NULL; }
    | expressaoMultiplicativa OPERADOR_DIVISAO expressaoExponencial       { $$ = NULL; }
    | expressaoMultiplicativa OPERADOR_MODULO expressaoExponencial        { $$ = NULL; }
    ;

expressaoExponencial
    : expressaoUnaria                                       { $$ = $1; }
    | expressaoUnaria OPERADOR_EXPONENCIACAO expressaoExponencial { $$ = NULL; }
    ;

expressaoUnaria
    : expressaoPosfixa                                      { $$ = $1; }
    | operadorUnario expressaoUnaria                        { $$ = NULL; }
    | A_PARENTESE tipoCast F_PARENTESE expressaoUnaria      { $$ = NULL; }
    ;

operadorUnario
    : OPERADOR_SUBTRACAO                                    { $$ = NULL; }
    | OPERADOR_NEGACAO                                      { $$ = NULL; }
    | OPERADOR_TAMANHO                                      { $$ = NULL; }
    ;

expressaoPosfixa
    : termo                                                 { $$ = $1; }
    | termo OPERADOR_INCREMENTO                             { $$ = NULL; }
    | termo OPERADOR_DECREMENTO                             { $$ = NULL; }
    ;

termo
    : ID {
        simbolo *s = buscar_simbolo(hash_table, pilha_escopos, $1);
        if (s == NULL) {
            printErro(ERRO_SEMANTICO, yylineno, "identificador '%s' nao declarado.", $1);
            $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));
        } else {
            $$ = createRecord(strdup($1), clonar_tipo(s->tipo));
        }
        free($1);
    }
    | ID sufixoId                                           { $$ = NULL; }
    | LITERAL_INTEIRO {
        char buf[32];
        sprintf(buf, "%d", $1);
        $$ = createRecord(strdup(buf), criar_tipo(T_INTEIRO, NULL, NULL));
    }
    | LITERAL_FLUTUANTE {
        char buf[64];
        sprintf(buf, "%f", $1);
        $$ = createRecord(strdup(buf), criar_tipo(T_FLUTUANTE, NULL, NULL));
    }
    | LITERAL_CARACTER {
        char buf[8];
        sprintf(buf, "'%c'", $1);
        $$ = createRecord(strdup(buf), criar_tipo(T_CARACTER, NULL, NULL));
    }
    | LITERAL_TEXTO {
        $$ = createRecord($1, criar_tipo(T_TEXTO, NULL, NULL));
    }
    | LITERAL_BOOLEANO {
        $$ = createRecord(strdup($1 ? "1" : "0"), criar_tipo(T_BOOLEANO, NULL, NULL));
    }
    | A_PARENTESE expressao F_PARENTESE {
        char *cod = cat("(", $2->code, ")", "", "");
        $$ = createRecord(cod, clonar_tipo($2->type));
        freeRecord($2);
    }
    | NOVO tipo A_PARENTESE listaExpressoesOpcional F_PARENTESE { $$ = NULL; }
    ;

sufixoId
    : listaIndexacao                                        { $$ = NULL; }
    | A_PARENTESE listaExpressoesOpcional F_PARENTESE     { $$ = NULL; }
    ;

listaIndexacao
    : A_COLCHETE expressao F_COLCHETE                       { $$ = NULL; }
    | listaIndexacao A_COLCHETE expressao F_COLCHETE        { $$ = NULL; }
    ;

listaExpressoesOpcional
    :                                                       { $$ = NULL; }
    | listaExpressoes                                       { $$ = NULL; }
    ;

listaExpressoes
    : expressao                                             { $$ = NULL; }
    | listaExpressoes VIRGULA expressao                     { $$ = NULL; }
    ;

tipoCast            : tipoEscalar                   { $$ = $1; }
                    | tipoDimensional               { $$ = $1; }
                    ;

tipo                : tipoCast                      { $$ = $1; }
                    | ID {
                        simbolo *s = buscar_simbolo(hash_table, pilha_escopos, $1);
                        if (s == NULL || s->categoria != CAT_TIPO_USUARIO) {
                            printErro(ERRO_SEMANTICO, yylineno, "tipo '%s' nao declarado.", $1);
                            $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));
                        } else {
                            $$ = createRecord(strdup($1), criar_tipo(T_USUARIO, $1, NULL));
                        }
                        free($1);
                    }
                    ;

tipoEscalar         : TIPO_INTEIRO      { $$ = createRecord(strdup("int"), criar_tipo(T_INTEIRO, NULL, NULL)); }
                    | TIPO_CARACTER     { $$ = createRecord(strdup("char"), criar_tipo(T_CARACTER, NULL, NULL)); }
                    | TIPO_FLUTUANTE    { $$ = createRecord(strdup("float"), criar_tipo(T_FLUTUANTE, NULL, NULL)); }
                    | TIPO_DECIMAL      { $$ = createRecord(strdup("double"), criar_tipo(T_DECIMAL, NULL, NULL)); }
                    | TIPO_TEXTO        { $$ = createRecord(strdup("char*"), criar_tipo(T_TEXTO, NULL, NULL)); }
                    | TIPO_BOOLEANO     { $$ = createRecord(strdup("int"), criar_tipo(T_BOOLEANO, NULL, NULL)); }
                    | TIPO_FILA         { $$ = createRecord(strdup("Fila*"), criar_tipo(T_FILA, NULL, NULL)); }
                    | TIPO_PILHA        { $$ = createRecord(strdup("Pilha*"), criar_tipo(T_PILHA, NULL, NULL)); }
                    | TIPO_DEQUE        { $$ = createRecord(strdup("Deque*"), criar_tipo(T_DEQUE, NULL, NULL)); }
                    | TIPO_CONJUNTO     { $$ = createRecord(strdup("Conjunto*"), criar_tipo(T_CONJUNTO, NULL, NULL)); }
                    | TIPO_GRAFO        { $$ = createRecord(strdup("Grafo*"), criar_tipo(T_GRAFO, NULL, NULL)); }
                    ;

tipoDimensional     : TIPO_VETOR MENOR tipo MAIOR {
                        Tipo *t_vetor = criar_tipo(T_VETOR, NULL, clonar_tipo($3->type));
                        char *cod_c = cat($3->code, "*", "", "", "");

                        $$ = createRecord(cod_c, t_vetor);
                        freeRecord($3);
                    }
                    ;

/* FIM DA PARTE QUE TA DANDO CONFLITO, PROVAVELMENTE */

%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_entrada> [arquivo_saida.c]\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Erro ao abrir arquivo de entrada");
        return 1;
    }

    if (argc >= 3) {
        arquivo_saida = fopen(argv[2], "w");
        if (!arquivo_saida) {
            perror("Erro ao criar arquivo de saida");
            fclose(yyin);
            return 1;
        }
    }

    pilha_escopos = criar_pilha();
    push(pilha_escopos, "global");
    hash_table = criar_tabela();

    int res = yyparse();

    liberar_tabela(hash_table);
    liberar_pilha(pilha_escopos);
    fclose(yyin);
    if (arquivo_saida) fclose(arquivo_saida);

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
