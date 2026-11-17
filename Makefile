CC = gcc
CFLAGS = -Wall -g -Ilib

TARGET = compiler

# Arquivos fontes das estruturas de dados em ./lib
LIB_SRCS = lib/pilha.c lib/hash_table.c

# Arquivos gerados pelo Flex e Bison
LEX_GEN = lex.yy.c
YACC_GEN = y.tab.c y.tab.h y.output y.vcg

all: $(TARGET)

# Passo final: compila e linka tudo no executável 'compiler'
$(TARGET): y.tab.c lex.yy.c $(LIB_SRCS)
	$(CC) $(CFLAGS) lex.yy.c y.tab.c $(LIB_SRCS) -o $(TARGET)

# Gera o parser (y.tab.c e y.tab.h) a partir do parser.y
y.tab.c y.tab.h: parser.y
	bison parser.y -o y.tab.c -d -v -g

# Gera o lexer (lex.yy.c) a partir do lexer.l (depende de y.tab.h existir)
lex.yy.c: lexer.l y.tab.h
	flex lexer.l

# Limpa todos os arquivos gerados para recompilar do zero
clean:
	rm -f $(TARGET) $(LEX_GEN) $(YACC_GEN)

.PHONY: all clean