CC = gcc
CFLAGS = -Wall -g -Ilib -Ibuild

SRC_DIR   = src
LIB_DIR   = lib
BUILD_DIR = build
TEST_DIR  = tests
C_OUT_DIR = $(TEST_DIR)/c_gerado
BIN_DIR   = $(BUILD_DIR)/bin

TARGET   = $(BUILD_DIR)/compiler
LIB_SRCS = $(wildcard $(LIB_DIR)/*.c)

LEX_C  = $(BUILD_DIR)/lex.yy.c
YACC_C = $(BUILD_DIR)/y.tab.c
YACC_H = $(BUILD_DIR)/y.tab.h

ARG  := $(word 2, $(MAKECMDGOALS))
NOME := $(basename $(notdir $(ARG)))

all: $(TARGET)

$(TARGET): $(YACC_C) $(LEX_C) $(LIB_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LEX_C) $(YACC_C) $(LIB_SRCS) -o $(TARGET)

$(YACC_C) $(YACC_H): $(SRC_DIR)/parser.y
	@mkdir -p $(BUILD_DIR)
	bison $(SRC_DIR)/parser.y -o $(YACC_C) -d -v -g

$(LEX_C): $(SRC_DIR)/lexer.l $(YACC_H)
	@mkdir -p $(BUILD_DIR)
	flex -o $(LEX_C) $(SRC_DIR)/lexer.l

# Traduz .nan -> .c em tests/c_gerado/ e compila o binário em build/bin/
# Uso: make compile problema1.nan
compile: $(TARGET)
	@mkdir -p $(C_OUT_DIR) $(BIN_DIR)
	$(eval ARQ_PATH := $(shell find $(TEST_DIR) -path $(C_OUT_DIR) -prune -o -name "$(ARG)" -print | head -n 1))
	@if [ -z "$(ARQ_PATH)" ]; then echo "Erro: '$(ARG)' nao encontrado em $(TEST_DIR)/"; exit 1; fi
	./$(TARGET) $(ARQ_PATH) $(C_OUT_DIR)/$(NOME).c
	$(CC) -I$(LIB_DIR) $(C_OUT_DIR)/$(NOME).c -o $(BIN_DIR)/$(NOME) -lm

%:
	@:

clean:
	rm -rf $(BUILD_DIR)/* $(C_OUT_DIR)/*.c

.PHONY: all compile clean