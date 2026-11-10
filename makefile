all:
	flex lexer.l
	bison parser.y -o y.tab.c -d -v -g
	gcc lex.yy.c y.tab.c -o compiler

clean:
	rm lex.yy.c y.gv y.output y.tab.c y.tab.h compiler
