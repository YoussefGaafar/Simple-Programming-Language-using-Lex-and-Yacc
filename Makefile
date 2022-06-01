build:
	flex Lexer.l
	yacc -v -d Parser.y
	gcc y.tab.c -o run.out

clean:
	rm -f y.tab.c y.tab.h y.output lex.yy.c run.out

all: clean build