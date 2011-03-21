%{
#include "lex.yy.c"

/* Pass the argument to yyparse through to yylex. */
// #define YYPARSE_PARAM scanner
// #define YYLEX_PARAM   scanner
#define YYPRINT

%}

%token AND
%token BGN
%token FORWARD
%token DIV
%token DO
%token ELSE
%token END
%token FOR
%token FUNC
%token IF
%token ARRAY
%token MOD
%token NOT
%token OF
%token OR
%token PROCEDURE
%token PROGRAM
%token RECORD
%token THEN
%token TO
%token TYPE
%token VAR
%token WHILE
%token MATH
%token RELATIONAL // < <= > >=
%token STOP // .
%token SEPARATOR // ,
%token DECLARE // :
%token EOL // ;
%token ASSIGNMENT // :=
%token RANGE
%token PAREN_L
%token PAREN_R
%token ARRAY_L
%token ARRAY_R
// COMPLICATED STUFF
%token NUMBER
%token ID
%token STRING_LITERAL
// wow, thats a lot of stuff.
// %token UNRECOG

%%
//rules go here
simple: ID EOL { printf("match: %d\n", $1);}
;
%%
//code goes here

//main function goes here
main( argc, argv )
int argc;
char **argv;
    {
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;
    int i = 0;
    yyparse();
    printf("printing symbol table\n");
    printSymbolTable(&symboltable);
    printf("printing number table\n");
    printSymbolTable(&numbertable);
}



