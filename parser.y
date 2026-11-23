%{
// libs padrão para lidar com strings e etc
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

// libs nossas para estruturas de dados, erros, etc
#include "pilha.h"
#include "hash_table.h"
#include "record.h"
#include "erros.h"
#include "tipos.h"
#include "semantica.h"


// declaração da tabela de simbolos e pilha com escopos
pilha *pilha_escopos;
HashTable *hash_table;

int yylex(void);
int yyerror(char *s);

// esses caras vem do lexer
extern int yylineno;
extern char * yytext;

// arquivo de entrada (na nosssa linguagem).
extern FILE *yyin;
// arquivo .c de saída (c simplificado)
FILE *arquivo_saida = NULL;

int struct_counter = 0;
int profundidade_laco = 0;

void novoEscopo(pilha *pilha, const char *prefixo);
void fecharEscopo();

%}

// acho que essa union é como uma capsula que armazena o valor atual
// de algum Types ou Token (lexama, ou atributos)
%union {
    int             iValue;
    char            *sValue;
    char            cValue;
    float           fValue;
    struct record   *rec; 
};

// declaração de que Tokens possuem lexemas 
%token <sValue> ID LITERAL_TEXTO
%token <iValue> LITERAL_INTEIRO LITERAL_BOOLEANO
%token <cValue> LITERAL_CARACTER
%token <fValue> LITERAL_FLUTUANTE

// declaração de que Types (LHS) são Records (ver record.h/.c)
%type <rec> cabecalho subprogramas instrucoes
%type <rec> constantes declaracaoConstante tipoUsuario
%type <rec> tipo tipoCast tipoEscalar tipoDimensional
%type <rec> expressao expressaoLogicaE expressaoRelacional expressaoAditiva
%type <rec> expressaoMultiplicativa expressaoExponencial expressaoUnaria
%type <rec> expressaoPosfixa termo sufixoId listaIndexacao
%type <rec> listaExpressoesOpcional listaExpressoes
%type <rec> instrucao condicionalSe listaSenaoSe senaoOpcional 
%type <rec> declaracao atribuicao inicializacao apenasAtribuicao cremento variavel
%type <rec> novoTipoUsuario tipoUsuarioDeclaracoes

// declaração dos Types (LHS) que são apenas strings
%type <sValue> operadorRelacional operadorUnario

// declaração de tokens usados em declaracoes
%token TIPO             CONSTANTE       FUNCAO
%token PROCEDIMENTO     NOVO

// declaração de tokens de tipos primitivos
%token TIPO_INTEIRO     TIPO_CARACTER   TIPO_FLUTUANTE
%token TIPO_DECIMAL     TIPO_TEXTO      TIPO_BOOLEANO

// declaração de tokens de tipos especiais
%token TIPO_FILA    TIPO_PILHA      TIPO_GRAFO
%token TIPO_DEQUE   TIPO_CONJUNTO 

// declaração de token de tipo estruturado
%token TIPO_VETOR

// declaração de tokens de controle de fluxo
%token SE_TOK           SENAO_TOK       SENAO_SE_TOK
%token PARA_TOK         ENQUANTO_TOK    PARE_TOK
%token ESCOLHA_TOK      CASO_TOK        RETORNE_TOK
%token CONTINUE_TOK     PADRAO_TOK  

// declaração de tokens de operadores aritméticos
%token OPERADOR_INCREMENTO      OPERADOR_DECREMENTO
%token OPERADOR_SOMA            OPERADOR_SUBTRACAO
%token OPERADOR_MULTIPLICACAO   OPERADOR_DIVISAO
%token OPERADOR_MODULO          OPERADOR_EXPONENCIACAO
%token OPERADOR_TAMANHO

// declaração de tokens de operadores lógicos
%token OPERADOR_OU      OPERADOR_E      OPERADOR_NEGACAO

// declaração de tokens de operadores relacionais
%token MENOR                    MAIOR
%token OPERADOR_ATRIBUICAO      OPERADOR_DIFERENTE      
%token OPERADOR_IGUAL           OPERADOR_MENOR_IGUAL  
%token OPERADOR_MAIOR_IGUAL  

// declaração de tokens de pontuação
%token VIRGULA      DOIS_PONTOS     TERMINADOR    
%token PONTO

// declaração de tokens de agrupamento/escopo
%token A_PARENTESE      F_PARENTESE
%token A_CHAVE          F_CHAVE
%token A_COLCHETE       F_COLCHETE

// regra inicial da gramática
%start programa

%%

programa    : cabecalho subprogramas instrucoes { 
                // se n capturou nenhum erro, faz a compilação para C simplificado
                if (totalErros() == 0) {
                    // concatena os códigos de "cabecalho", "subprogramas" e "instrucoes"
                    char *temp_final = cat($1->code, "\n", $2->code, "\n", "");
                    char *codigo_final = cat(temp_final, "int main() {\n", $3->code, "};", "");
                    // se o arquivo de saida não for um ponteiro null, cospe o C simplificado no arquivo
                    // se for null, ai só faz um printf no console mesmo do C simplificado
                    if (arquivo_saida != NULL) {
                        fprintf(arquivo_saida, "%s\n", codigo_final);
                    } else {
                        printf("%s\n", codigo_final);
                    }

                    // libera ponteiro do char* declarado. mt importante sempre dar free.
                    free(temp_final);
                    free(codigo_final);
                } else {
                    // se tiver erro, mostra quantos
                    printf("Compilação abortada com %d erros(s).\n", totalErros());
                }

                // libera os records dos não terminais RHS "cabecalho", "subprogramas", "instrucoes"
                freeRecord($1);
                freeRecord($2);
                freeRecord($3);
            }
            ;

cabecalho   : constantes tipoUsuario    {
                // concat de código dos não terminais
                char *code = cat($1->code, "\n", $2->code, "", "");

                // free dos records 
                freeRecord($1);
                freeRecord($2);

                /* $$ é o "retorno" do LHS.
                    logo, aqui está criando um record (é como uma capsula)
                    onde o LHS "cabecalho" vai receber essa capsula.
                    é como os nós filhos de comunicam com os pais, na árvore. */

                // cria record para $$ com a concatenação "code" e type NULL
                $$ = createRecord(strdup(code), NULL);

                // libera o ponteiro de "code"
                free(code);
            } 
            ; 

constantes  :                                           { 
                // se não tiver constantes, ele só "sobe" o record para o pai
                $$ = createRecord(strdup(""), NULL); 
            }  
            | constantes declaracaoConstante TERMINADOR { 
                // concatenação
                char *code = cat($1->code, "", $2->code, ";\n", "");
                // free dos não terminais
                freeRecord($1);
                freeRecord($2);
                // subida record com codigo concatenado para o pai
                $$ = createRecord(strdup(code), NULL);    
                // free no ponteiro
                free(code);
            }   
            ; 

declaracaoConstante : CONSTANTE tipo ID OPERADOR_ATRIBUICAO expressao { 
                        // aqui começa com a inicialização do record. 
                        $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));
                        
                        // faz a busca de achou "ID" na tabela de simbolos.
                        simbolo *sym_1 = buscar_simbolo(hash_table, pilha_escopos, $3);

                        // se achou o simbolo, quer dizer que essa variável ja existe e está sendo redeclarada
                        if (sym_1 != NULL) {
                            printErro(ERRO_SEMANTICO, yylineno, "constante '%s' já declarada na linha %d.", $3, sym_1->linha_declaracao);
                            // se tiver erro, vai pro GOTO fim_declaracaoConstante
                            goto fim_declaracaoConstante;
                        }

                        // aqui faz a validação de tipos (coerção está envolvida). consultar a função para mais informações
                        // basicamente compara se o tipo do não terminal "tipo" pode receber o tipo do não terminal "expressao"
                        if (!tipos_compativeis($2->type, $5->type)) {
                            printErro(ERRO_SEMANTICO, yylineno, "tipo incompativel na declaração da constante '%s'.", $3);
                            // se tiver erro, vai pro GOTO fim_declaracaoConstante
                            goto fim_declaracaoConstante;
                        }

                        // se não tiver nenhum problema, insere o novo simbolo na tabela de simbolos
                        inserir_simbolo(hash_table, pilha_escopos, $3, $2->type, CAT_CONSTANTE, yylineno);
                        // como n teve erros, faz free nos atributos do record pra colocar os novos
                        free($$->code);
                        liberar_tipo($$->type);

                        // code recebe a concatenação do texto em C simplificado da declaração de constante
                        char *temp = cat("const ", $2->code, " ", $3, " = ");
                        $$->code = cat(temp, $5->code, "", "", "");
                        // o tipo recebe justamente o não terminal "tipo", que está na segunda posição. 
                        $$->type = clonar_tipo($2->type);

                        // free no ponteiro
                        free(temp);

                    // label de goto onde termina a semantica, fazendo free nos records e ponteiro. 
                    fim_declaracaoConstante:
                        freeRecord($2);
                        freeRecord($5);
                        free($3);
                    }
                    ;

tipoUsuario :                                           { $$ = createRecord(strdup(""), NULL); }
            | tipoUsuario novoTipoUsuario TERMINADOR    { 
                // concatenação
                char *code_tipoUsuario = cat($1->code, "", $2->code, ";\n", "");
                // free dos não terminais
                freeRecord($1);
                freeRecord($2);
                // subida record com codigo concatenado para o pai
                $$ = createRecord(strdup(code_tipoUsuario), NULL);    
                // free no ponteiro
                free(code_tipoUsuario);
             }
            ;

novoTipoUsuario : TIPO A_CHAVE {
                    char escopo_tmp[32];
                    sprintf(escopo_tmp, "struct_%d", struct_counter++);
                    push(pilha_escopos, escopo_tmp);
                  } tipoUsuarioDeclaracoes F_CHAVE ID {
                    $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));

                    pop(pilha_escopos);

                    simbolo *sym_3 = buscar_simbolo(hash_table, pilha_escopos, $6);
                          
                    if (sym_3 != NULL) {
                        printErro(ERRO_SEMANTICO, yylineno, "tipo '%s' já declarado na linha %d.", $6, sym_3->linha_declaracao);
                        goto fim_novoTipoUsuario;
                    }

                    Tipo *t_usuario = criar_tipo(T_USUARIO, $6, NULL);
                    inserir_simbolo(hash_table, pilha_escopos, $6, t_usuario, CAT_TIPO_USUARIO, yylineno);

                    free($$->code);
                    liberar_tipo($$->type);

                    $$->code = cat("typedef struct {\n", $4->code, "} ", $6, "");
                    $$->type = t_usuario;

                fim_novoTipoUsuario:
                    freeRecord($4);
                    free($6);
                }
                ;

tipoUsuarioDeclaracoes  : declaracao TERMINADOR {
                            $$ = createRecord(cat("    ", $1->code, ";\n", "", ""), NULL);
                            freeRecord($1);
                        }
                        | declaracao TERMINADOR tipoUsuarioDeclaracoes {
                            char *linha = cat("    ", $1->code, ";\n", "", "");
                            $$ = createRecord(cat(linha, $3->code, "", "", ""), NULL);
                            free(linha);
                            freeRecord($1);
                            freeRecord($3);
                        }
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
            | instrucao TERMINADOR instrucoes   { 
                $$ = createRecord(cat($1->code, ";\n", $3->code, "", ""), NULL); 
                freeRecord($1); 
                freeRecord($3); 
            } 
            ;

instrucao   : declaracao            { $$ = $1; } 
            | atribuicao            { $$ = $1; }
            | condicionalSe         { $$ = $1; }
            | condicionalCaso       {}
            | lacoPara              {}
            | lacoEnquanto          {}
            | chamadaSubprograma    {}
            | controle              {}
            | retorno               {}
            ;

atribuicao          : inicializacao       { $$ = $1; }
                    | apenasAtribuicao       { $$ = $1; }
                    ;

inicializacao : declaracao OPERADOR_ATRIBUICAO expressao  {
    /* Exemplo usado nos comentários:   inteiro idade = 20;
     *
     * Quando esta ação roda, o parser já reconheceu a linha inteira:
     *   $1 = record de 'declaracao'  -> code: "int idade"  | type: T_INTEIRO
     *   $2 = o token '='             -> não carrega valor, por isso não é usado
     *   $3 = record de 'expressao'   -> code: "20"         | type: T_INTEIRO */

    bool tiposCompativeis = tipos_compativeis($1->type, $3->type);
    /* Pergunta: "um valor do tipo $3 pode ser guardado numa variável do tipo $1?"
     * A ordem importa: (destino, origem), e a função é direcional.
     *   inteiro idade = 20;      -> (inteiro, inteiro)   -> true
     *   flutuante f = 20;        -> (flutuante, inteiro) -> true  (inteiro vira flutuante)
     *   inteiro n = 1.5;         -> (inteiro, flutuante) -> false (perderia a parte decimal)
     *   inteiro n = "texto";     -> (inteiro, texto)     -> false
     * O 'bool' exige #include <stdbool.h> no prólogo do parser.y. */

    if (!tiposCompativeis) {
        /* Só entra aqui nos exemplos "false" acima, como  inteiro n = 1.5; */
        printErro(ERRO_SEMANTICO, yylineno, "Tipos incompativeis na atribuicao.");
        /* Imprime algo como "erro semântico na linha 7: Tipos incompativeis..."
         * e incrementa o contador de erros. A análise continua para achar outros
         * erros, mas, no fim, o programa vê totalErros() > 0 e não gera o C. */
    }

    $$ = createRecord(cat($1->code, " = ", $3->code, "", ""), NULL);
    /* Monta o código C da inicialização juntando os pedaços:
     *   "int idade" + " = " + "20"   ->   "int idade = 20"
     * O ';' não entra aqui: quem o acrescenta é a regra 'instrucoes'.
     * O 2º argumento é NULL porque uma atribuição não é uma expressão, ou seja,
     * não tem tipo para repassar. Quem usa o resultado só precisa do código. */

    freeRecord($1);
    /* Libera o record de "int idade". O cat() já copiou o texto para a string
     * nova do $$, então o original não é mais necessário. */

    freeRecord($3);
    /* Libera o record de "20", pelo mesmo motivo. */
}
;
                        ;

variavel
    : ID                                            {
        /* Exemplo usado nos comentários:   idade = 21;
         *
         * Esta regra reconhece o LADO ESQUERDO de uma atribuição.
         * Quando a ação roda, o lexer já entregou o token ID:
         *   $1 = string "idade" (alocada com strdup no lexer, então é nossa) */

        simbolo *s = buscar_simbolo(hash_table, pilha_escopos, $1);
        /* Procura "idade" na tabela de símbolos, do escopo atual subindo até o global.
         *   Achou  -> s aponta para o símbolo (com categoria e tipo)
         *   Não achou -> s == NULL
         * Exemplo: se antes houve `inteiro idade = 20;`, s->tipo é T_INTEIRO
         * e s->categoria é CAT_VARIAVEL. */

        Tipo *tipoDaVariavel;
        /* Vai guardar o tipo que esta variável terá como atributo. Cada ramo
         * abaixo atribui um valor, então nunca é lido sem inicializar. */

        if (s == NULL) {
            /* Caso: `z = 1;` sem nunca ter declarado 'z' */
            printErro(ERRO_SEMANTICO, yylineno, "identificador %s nao declarado.", $1);
            /* Imprime algo como "erro semântico na linha 5: identificador z nao declarado."
             * e conta o erro. No fim, totalErros() > 0 impede a geração do C. */
            tipoDaVariavel = criar_tipo(T_ERRO, NULL, NULL);
            /* T_ERRO é aceito por tipos_compativeis de propósito: a atribuição
             * `z = 1;` não gera uma SEGUNDA mensagem de "tipo incompatível".
             * Um erro, uma mensagem. */
        }
        //else if (s->categoria == CAT_CONSTANTE) {
        //    /* Caso: `constante inteiro MAX = 10;` e depois `MAX = 20;` */
        //    printErro(ERRO_SEMANTICO, yylineno, "não é possível modificar a constante '%s'.", $1);
        //    /* "erro semântico na linha 8: não é possível modificar a constante 'MAX'." */
        //    tipoDaVariavel = criar_tipo(T_ERRO, NULL, NULL);
        //    /* Mesmo motivo: evita cascata de erros nesta linha. */
        //}
        //else if (s->categoria != CAT_VARIAVEL) {
        //    /* Caso: o nome existe, mas é outra coisa, como uma função.
        //     * Ex.: `funcao inteiro soma(...)` e depois `soma = 3;` */
        //    printErro(ERRO_SEMANTICO, yylineno, "'%s' nao é uma variavel.", $1);
        //    /* "erro semântico na linha 9: 'soma' nao é uma variavel." */
        //    tipoDaVariavel = criar_tipo(T_ERRO, NULL, NULL);
        //}
        else {
            /* Caso normal: existe e é variável. Ex.: `idade = 21;` com 'idade' declarada. */
            tipoDaVariavel = clonar_tipo(s->tipo);
            /* Copia o tipo da tabela (T_INTEIRO no exemplo). É cópia, e não o
             * ponteiro da tabela, porque o record vai liberar este Tipo com
             * freeRecord; liberar o original da tabela corromperia os próximos usos. */
        }

        $$ = createRecord(strdup($1), tipoDaVariavel);
        /* Monta o record que sobe para a regra de atribuição:
         *   code = "idade"   (o texto C do lado esquerdo, igual ao nome)
         *   type = T_INTEIRO (ou T_ERRO nos casos de erro)
         * A regra seguinte usa o type para checar `idade = 1.5;` (incompatível)
         * e o code para montar "idade = 21". */

        free($1);
        /* Libera a string "idade" que o lexer alocou. O strdup acima já fez uma
         * cópia para o record, então o original não é mais necessário. */
    }
    | variavel PONTO ID                             {}
    | variavel A_COLCHETE expressao F_COLCHETE      {}
    ;

apenasAtribuicao : variavel OPERADOR_ATRIBUICAO expressao            {
    /* Exemplo:   idade = 21;   (com 'idade' já declarada como inteiro)
     *
     * Quando esta ação roda, o parser já reconheceu a linha inteira:
     *   $1 = record de 'variavel'  -> code: "idade"  | type: T_INTEIRO
     *   $2 = o token '='           -> não carrega valor, por isso não é usado
     *   $3 = record de 'expressao' -> code: "21"     | type: T_INTEIRO
     *
     * Diferença para 'inicializacao': aqui NINGUÉM insere símbolo na tabela. A
     * variável já tem que existir, e quem confere isso é a regra 'variavel'. */

    int tiposCompativeis = tipos_compativeis($1->type, $3->type);
    /* Pergunta: "um valor do tipo $3 pode ser guardado numa variável do tipo $1?"
     * A ordem importa: (destino, origem), e a função é direcional.
     *   idade = 21;     -> (inteiro, inteiro)   -> 1 (verdadeiro)
     *   f = 21;         -> (flutuante, inteiro) -> 1 (inteiro vira flutuante)
     *   idade = 1.5;    -> (inteiro, flutuante) -> 0 (perderia a parte decimal)
     *   idade = "ana";  -> (inteiro, texto)     -> 0
     * Se a variável não existe (`z = 1;`), $1->type é T_ERRO, que a função aceita
     * de propósito: o erro de "não declarado" já foi dado em 'variavel', e aqui
     * não sai uma segunda mensagem para a mesma linha. */

    if (!tiposCompativeis) {
        /* Só entra nos exemplos "0" acima, como  idade = 1.5; */
        printErro(ERRO_SEMANTICO, yylineno, "tipo incompativel na atribuicao.");
        /* Imprime algo como "erro semântico na linha 6: tipo incompativel na atribuicao."
         * e conta o erro. A análise continua para achar outros erros, e no fim
         * totalErros() > 0 impede a geração do C. */
    }

    $$ = createRecord(cat($1->code, " = ", $3->code, "", ""), NULL);
    /* Monta o código C juntando os pedaços:
     *   "idade" + " = " + "21"   ->   "idade = 21"
     * Funciona também com vetor, porque o code de 'variavel' já vem montado:
     *   v[2] = 7;   ->   "v[2] = 7"
     * O ';' não entra aqui: quem o acrescenta é a regra 'instrucoes'. Isso é
     * importante porque esta regra também é usada no cabeçalho do 'para'
     * (`for (...; ...; i = i + 1)`), onde um ';' extra quebraria o C.
     * O 2º argumento é NULL porque uma atribuição não é expressão: não tem tipo
     * para repassar. */

    freeRecord($1);
    /* Libera o record de "idade". O cat() já copiou o texto para a string nova
     * do $$, então o original não é mais necessário. */

    freeRecord($3);
    /* Libera o record de "21", pelo mesmo motivo. */
}
                        | cremento                                          { $$ = $1; }
                        ;

cremento : variavel OPERADOR_INCREMENTO                      {
    /* Exemplo usado nos comentários:   idade++;   (com 'idade' declarada como inteiro)
     *
     * Quando esta ação roda, o parser já reconheceu "idade++":
     *   $1 = record de 'variavel'  -> code: "idade"  | type: T_INTEIRO
     *   $2 = o token '++'          -> não carrega valor, por isso não é usado
     *
     * Aqui não há expressão do lado direito, então não existe checagem de
     * compatibilidade entre dois tipos. O que se verifica é se a PRÓPRIA
     * variável aceita o operador. */

    CategoriaTipo c = $1->type->categoria;
    /* Pega só a "família" do tipo da variável, que é o que interessa aqui:
     *   idade     -> T_INTEIRO
     *   altura    -> T_FLUTUANTE
     *   nome      -> T_TEXTO
     *   z (não declarada) -> T_ERRO (a regra 'variavel' sempre devolve um tipo,
     *                                então o ponteiro $1->type nunca é NULL) */

    if (c != T_ERRO && c != T_INTEIRO && c != T_FLUTUANTE && c != T_DECIMAL) {
        /* Só entra se o tipo NÃO for numérico, e também NÃO for T_ERRO.
         * Exemplos que entram:  nome++;  (texto)    ativo++;  (booleano)
         * Exemplos que não entram: idade++; (inteiro)   altura++; (flutuante)
         * O T_ERRO fica de fora de propósito: em `z++;` com 'z' inexistente, o erro
         * "identificador z nao declarado" já foi dado em 'variavel', e aqui
         * não sai uma segunda mensagem para a mesma linha. */
        printErro(ERRO_SEMANTICO, yylineno, "operador '++' exige variável numérica.");
        /* "erro semântico na linha 4: operador '++' exige variável numérica."
         * e conta o erro. No fim, totalErros() > 0 impede a geração do C. */
    }

    $$ = createRecord(cat($1->code, "++", "", "", ""), NULL);
    /* Monta o código C juntando os pedaços:
     *   "idade" + "++"   ->   "idade++"
     * Funciona também com vetor, porque o code de 'variavel' já vem montado:
     *   v[2]++;   ->   "v[2]++"
     * O ';' não entra aqui: quem o acrescenta é a regra 'instrucoes'. Isso importa
     * porque esta regra também aparece no cabeçalho do 'para'
     * (`for (inteiro i = 0; i < 3; i++)`), onde um ';' extra quebraria o C.
     * O 2º argumento é NULL porque `idade++;` é uma instrução, e não uma
     * expressão com tipo para repassar. */

    freeRecord($1);
    /* Libera o record de "idade". O cat() já copiou o texto para a string nova
     * do $$, então o original não é mais necessário. */
}
                    ;

declaracao          : tipo ID                                              {   
                        $$ = createRecord(strdup(""), criar_tipo(T_ERRO, NULL, NULL));

                        simbolo *sym_2 = buscar_simbolo(hash_table, pilha_escopos, $2);
                        
                        if (sym_2 != NULL) {
                            printErro(ERRO_SEMANTICO, yylineno, "variável '%s' já declarada na linha %d.", $2, sym_2->linha_declaracao);
                            goto fim_declaracao;
                        }
                        
                        inserir_simbolo(hash_table, pilha_escopos, $2, $1->type, CAT_VARIAVEL, yylineno);

                        free($$->code);
                        liberar_tipo($$->type);

                        $$->code = cat($1->code, " ", $2, "", "");
                        $$->type = clonar_tipo($1->type);
                        
                    fim_declaracao:
                        freeRecord($1);
                        free($2);
                    } 
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
                    | listaSenaoSe SENAO_SE_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE { push(pilha_escopos, "bloco_senaoSe"); } instrucoes { pop(pilha_escopos); } F_CHAVE    {
                        verificarCondicaoBool($4, "senaose", yylineno);

                        char *instrucaoSenaoSe = cat(" else if (", $4->code, ") {\n", $8->code, "}");

                        $$ = createRecord(cat($1->code, instrucaoSenaoSe, "", "", ""), NULL);

                        free(instrucaoSenaoSe);
                        freeRecord($1);
                        freeRecord($4);
                        freeRecord($8);
                    }
                    ;

senaoOpcional       :                                       { $$ = createRecord(strdup(""), NULL); }
                    | SENAO_TOK A_CHAVE { push(pilha_escopos, "bloco_senao"); } instrucoes { pop(pilha_escopos); } F_CHAVE  {
                        $$ = createRecord(cat(" else {\n", $4->code, "}", "", ""), NULL);

                        freeRecord($4);
                    }
                    ;

condicionalCaso     : ESCOLHA_TOK A_PARENTESE expressao F_PARENTESE A_CHAVE listaCasos PADRAO_TOK DOIS_PONTOS instrucoes F_CHAVE {} ;

listaCasos          :                                                       {}
                    | listaCasos CASO_TOK expressao DOIS_PONTOS instrucoes  {} 
                    ;

lacoPara            : PARA_TOK A_PARENTESE inicializacao TERMINADOR expressao TERMINADOR apenasAtribuicao F_PARENTESE A_CHAVE instrucoes F_CHAVE {}
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
    : OPERADOR_IGUAL                                        { $$ = strdup("=="); }
    | OPERADOR_DIFERENTE                                    { $$ = strdup("!="); }
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
    : variavel                                              { $$ = $1; }
    | ID A_PARENTESE listaExpressoesOpcional F_PARENTESE    { $$ = NULL; }
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

%%

// programa main, que vai faz o parse do código na linguagem de origem
int main(int argc, char **argv) {
    // se tiver menos de 2 argumentos tá sendo utilizado errado
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_entrada> [arquivo_saida.c]\n", argv[0]);
        return 1;
    }

    // le o arquivo de entrada na linguagem origem
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Erro ao abrir arquivo de entrada");
        return 1;
    }

    // se tiver mais de 3 argumentos, ai ta certo o uso
    if (argc >= 3) {
        arquivo_saida = fopen(argv[2], "w");
        if (!arquivo_saida) {
            perror("Erro ao criar arquivo de saida");
            fclose(yyin);
            return 1;
        }
    }

    // incializa pilha
    pilha_escopos = criar_pilha();
    // pusha o escopo global ("piso" da pilha) para a pilha
    // o motivo é que na nossa linguagem o escopo já é global, desde o início
    push(pilha_escopos, "global");
    hash_table = criar_tabela();

    int res = yyparse();

    liberar_tabela(hash_table);
    liberar_pilha(pilha_escopos);
    fclose(yyin);

    if (arquivo_saida) 
        fclose(arquivo_saida);

    return res;
}

// função de erro padrão de sintaxe, acho que não está sendo utilizada,
// mas se tirar daqui e do cabeçalho dá erro de referencia
int yyerror (char *msg) {
    fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
    return 0;
}


void novoEscopo(pilha *pilha, const char *prefixo) {
    char idEscopo[64];
    sprintf(idEscopo, "%s_%d", prefixo, struct_counter);

    push(pilha_escopos, idEscopo);
}

void fecharEscopo() {
    pop(pilha_escopos);
}
