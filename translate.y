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
%token ADDOP
%token MULTIOP
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
        PROGRAM ID EOL typeDefinitions variableDeclarations subprogramDeclarations compoundStatement STOP
            {reg("program");}
        ;

variableDeclarations: 
        VAR multiVarDeclarations
            {reg("variableDeclarations");}
        | /*empty*/
        ;
multiVarDeclarations:
        variableDeclaration EOL multiVarDeclarations
        | variableDeclaration EOL
        ;
variableDeclaration:
        identifierList DECLARE type
            {
                updateAll($<table>1, $<table>3->symbol);
                reg("variableDeclaration");
            }
        ;
        
identifierList:
        ID multiIds
        {
            printf("identifierList!");
            $<table>$ = (symbol_entry) malloc(sizeof(struct s_entry));
            
            $<table>$->symbol = malloc(sizeof($<table>1->symbol));
            
            strcpy($<table>$->symbol, $<table>1->symbol);
            if($<table>2) {
                printf("joining chain\n");
                printf("next value: '%s'\n", $<table>2->symbol);
                $<table>$->next = $<table>2;
                }
            
            /*$<intVal>$ = 1 + $<intVal>2; */
            reg("identifierList");
            
        }
        ;
multiIds: SEPARATOR identifierList
        {
            $<table>$ = $<table>2;
/*            $<intVal>$ = $<intVal>2;*/
        }
        | /*empty*/
        {$<intVal>$ = 0; $<table>$ = NULL;}
        ;
subprogramDeclarations:
        procedureDeclaration EOL subprogramDeclarations
            {reg("subprogramDeclarations");}
        | functionDeclaration EOL subprogramDeclarations
            {reg("subprogramDeclarations");}
        | /*empty*/
        ;
functionDeclaration: 
        FUNC ID PAREN_L formalParameterList PAREN_R DECLARE resultType EOL blockOrForward
        {
            char asString[50];
            sprintf(asString, "%d", $<intVal>4);
            updateSymbolTable($<table>2->symbol, asString);
            reg("functionDeclaration");
        }
        ;
resultType:
    ID
    {reg("resultType");}
    ;
        
procedureDeclaration:
        PROCEDURE ID PAREN_L formalParameterList PAREN_R EOL blockOrForward
        {//here we want to set the type of ID to be the length of the formalParameterList
            char asString[50];
            sprintf(asString, "%d", $<intVal>4);
            updateSymbolTable($<table>2->symbol, asString);
            reg("procedureDeclaration");
            }
        ;
blockOrForward:
    block | FORWARD
    ;
    
block:  variableDeclarations compoundStatement
    {reg("block");}

paramDeclare:
    identifierList DECLARE type
    {
        updateAll($<table>1, $<table>3->symbol);
    }
    ;

paramList:
        paramList EOL paramDeclare
        {$<intVal>$ = $<intVal>1 + $<intVal>3;}
        | paramDeclare 
        {$<intVal>$ = $<intVal>1;}
        ;
formalParameterList:
        paramList 
        {reg("formalParameterList");}
        | /*empty*/
        {$<intVal>$ = 0;}
        ;

compoundStatement:
        BGN statementSequence END
        {reg("compoundStatement");}
        ;

statementSequence:
        statement EOL statementSequence
        {reg("statementSequence");}
        | statement
        {reg("statementSequence");}
        ;
statement:
    open
    {reg("statement");}
    | matched
    {reg("statement");}
    ;

otherStatements:
    compoundStatement
    {reg("structuredStatement");}
    | simpleStatement
    {reg("simpleStatement");}
    ;
loopHeader:
    FOR ID ASSIGNMENT expression TO expression DO
    | WHILE expression DO

open:
    IF expression THEN statement
        {reg("structuredStatement");}
    | IF expression THEN matched ELSE open
        {reg("structuredStatement");}
    | loopHeader open
        {reg("structuredStatement");}
    ;
matched:
    IF expression THEN matched ELSE matched
        {reg("structuredStatement");}
    | otherStatements
        {reg("structuredStatement");}
    | loopHeader matched
        {reg("structuredStatement");}
    ;


simpleStatement:
    assignmentStatement
    | procedureStatement
    | /*empty*/
    ;
assignmentStatement:
        variable ASSIGNMENT expression
            {reg("assignmentStatement");}
        ;
procedureStatement:
        ID PAREN_L actualParameterList PAREN_R
        {reg("procedureStatement");}
        ;
apList:
        expression SEPARATOR apList
        | expression
        ;
actualParameterList:
        apList 
        {reg("actualParameterList");}
        | /*empty*/
        ;
        
variable:
    ID componentSelection
    {reg("variable");}
    ;
componentSelection:
    STOP ID componentSelection
        {reg("componentSelection");}
    | ARRAY_L expression ARRAY_R componentSelection
        {reg("componentSelection");}
    | /*empty*/
    ;
expression:
    simpleExpression relationalOp simpleExpression
        {reg("expression");}
    | simpleExpression
        {reg("expression");}
    ;
    
addOpTerm:
    addOp term addOpTerm
    | /*empty*/
    ;
relationalOp:
    RELATIONAL | EQUALS
        {reg("relationalOp");}
    ;
mulOpFactor:
    mulOp factor mulOpFactor
    | /*empty*/
    ;
term:
    factor mulOpFactor
        {reg("term");}
    ;
factorOptions:
    INT 
    | STRING_LITERAL
    | variable 
    | functionReference 
    | NOT factor 
    | PAREN_L expression PAREN_R
    ;
factor:
    factorOptions
        {reg("factor");}
    ;
functionReference:
    ID PAREN_L actualParameterList PAREN_R
        {reg("functionReference");}
    ;

simpleExpression:
    sign term addOpTerm
        {reg("simpleExpression");}
    ;
addOp:
    ADDOP 
        {reg("addOp");}
    | OR
        {reg("addOp");}
    ;
mulOp:
    MULTIOP 
        {reg("mulOp");}
    | MOD 
        {reg("mulOp");}
    | AND
        {reg("mulOp");}
    ;
sign:
    ADDOP {reg("sign");} | /*empty*/
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
        | RECORD fieldList END
            {
                reg("type"); 
                $<table>$ = (symbol_entry) malloc(sizeof(struct s_entry));
                char* joined = join($<table>2);
                printf("joined: %s\n", joined);
                $<table>$->symbol = malloc(sizeof("record containing ") + sizeof(joined));
                sprintf($<table>$->symbol, "%s%s", "record containing ", joined);
            }
        | ID
        {
            reg("type");
            
            }
        ;

fieldList:
    paramDeclare EOL fieldList
    {   
        $<table>$ = $<table>1;
        $<table>$->next = $<table>3;
        reg("fieldList");   
    }
    | paramDeclare
    {
        reg("fieldList");
    }
    ;

%%
//code goes here

//main function goes here
main( argc, argv )
int argc;
char **argv;
    {
    ++argv, --argc;  /* skip over program name */
    
    if ( argc == 0 ) exit(1);
            
    yyin = fopen( argv[0], "r" );

    int i = 0;
    parsefile = fopen("rules.out", "w");
    yyparse();
    fclose(parsefile);
    fclose(yyin);
    printf("printing symbol table to symtable.out\n");
    printSymbolTables("symtable.out");
    
    
}



