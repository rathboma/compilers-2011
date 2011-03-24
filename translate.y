%{
#include "lex.yy.c"
//#include "symbol_table.h"
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
%token EQUALS
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
%token FLOAT
%token INT
%token ID
%token STRING_LITERAL
// wow, thats a lot of stuff.
// %token UNRECOG

%union {
    int intVal;
    double doubleVal;
    char* strVal;
    symbol_entry table;
}

%%
//rules go here
program: 
        PROGRAM ID EOL typeDefinitions variableDeclarations subprogramDeclarations compoundStatement
            {reg("program");}
        ;

variableDeclarations: 
        VAR multiVarDeclarations
            {reg("variableDeclarations");}
        | /*empty*/
        ;
multiVarDeclarations:
        variableDeclaration EOL multiVarDeclarations
        | /*empty*/
        ;
variableDeclaration:
        identifierList DECLARE type
            {reg("variableDeclaration");}
        ;
        
identifierList:
        ID multiIds
        {$<intVal>$ = 1 + $<intVal>2;}
        ;
multiIds: SEPARATOR identifierList
        {$<intVal>$ = $<intVal>2;}
        | /*empty*/
        {$<intVal>$ = 0;}
        ;
subprogramDeclarations:
        procedureDeclaration EOL
        | functionDeclaration EOL
        | /*empty*/
        ;
functionDeclaration: /*empty*/
        ;
        
procedureDeclaration:
        PROCEDURE ID PAREN_L formalParameterList PAREN_R EOL blockOrForward
        {//here we want to set the type of ID to be the length of the formalParameterList
            char* asString = "";
            sprintf(asString, "%d", $<intVal>4);
            updateSymbolTable($<table>2->symbol, asString);
            }
        ;
blockOrForward:
    block | FORWARD
    ;
    
block:  variableDeclarations compoundStatement
    {reg("block");}
paramList:
        paramList EOL identifierList DECLARE type
        {$<intVal>$ = $<intVal>1 + $<intVal>3; }
        | identifierList DECLARE type 
        {$<intVal>$ = $<intVal>1;}
        ;
formalParameterList:
        paramList 
        {reg("formalParameterList");}
        | /*empty*/
        {$<intVal>$ = 0;}
        ;



compoundStatement:
        /*empty*/
        ;

typeDefinitions: TYPE multipleTypeDefs
            {reg("typeDefinitions");}
            | /*empty*/
        ;
multipleTypeDefs: typeDefinition multipleTypeDefs
            | /* empty */
        ;

typeDefinition:
        ID EQUALS type EOL
            {   //printf("typeDefinition for %s, type = %s\n", $<table>1->symbol, $<table>3->symbol);
                reg("typeDefinition");
                updateSymbolTable($<table>1->symbol, $<table>3->symbol);
             }
        ;

type: ARRAY ARRAY_L INT RANGE INT ARRAY_R OF type
            {reg("type"); 
                $<table>$ = (symbol_entry) malloc(sizeof(struct s_entry));
                $<table>$->symbol = malloc(sizeof("array of ") + sizeof($<table>8->symbol));
                sprintf($<table>$->symbol, "%s%s", "array of ", $<table>8->symbol);
                }
        | ID
        {reg("type");}
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



