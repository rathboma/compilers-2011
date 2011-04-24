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
    token chain;
    type_entry type;
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
            token t = $<chain>1;
            while(t){
                installSymbol(currentSymbolTable, t->value, $<type>3, BASICSYM);
                t = t->next;
            }
        }
        ;
        
identifierList:
        ID multiIds
        {
            
            $<chain>$ = (token) malloc(sizeof(struct token_struct));
            $<chain>$->value = calloc(strlen($<strVal>1), sizeof(char));
            strcpy($<chain>$->value, $<strVal>1 );
            $<chain>$->next = $<chain>2;
            reg("identifierList");
        }
        ;
multiIds: SEPARATOR identifierList
        {
            $<chain>$ = $<chain>2;

        }
        | /*empty*/
        {

            $<chain>$ = NULL;
        }
        ;
subprogramDeclarations:
        procedureDeclaration EOL subprogramDeclarations
            {reg("subprogramDeclarations");}
        | functionDeclaration EOL subprogramDeclarations
            {reg("subprogramDeclarations (function)");}
        | /*empty*/
        ;
functionDeclaration: 
        func ID PAREN_L formalParameterList PAREN_R DECLARE resultType EOL blockOrForward
        {
            printf("function.\n");
            token t = $<chain>4;
            
            symbol_entry func = installSymbol(currentSymbolTable->parent, $<strVal>2, $<type>7, FUNCTIONSYM);
            printf("installed symbol entry for function %s\n", func->symbol );

            func->numParameters = lengthOf(t);
            printf("number of parameters: %d\n", func->numParameters);
            func->innerScope = currentSymbolTable;
            int i = 0;
            while(t){

                symbol_entry s = findSymbol(currentSymbolTable, t->value, 0, BASICSYM);
                printf("adding symbol entry to parameters list: %s\n", s->symbol );
                func->parameters[i] = s;
                i++;
                t = t->next;
            }
            $<type>$ = $<type>7;
            retreat();
            
            //formalParameterList = list of tokens
            //add them all to the symbol table
            // add each symbol to the params array
            //retreat();
            
        }
        ;
resultType:
    ID
    {
        $<type>$ = resolveType(currentSymbolTable->parent, $<strVal>1);
        reg("resultType");
    }
    ;
func:
FUNC
{
    advance();
}
;
proc:
PROCEDURE
{
    advance();
}
;

procedureDeclaration:
        proc ID PAREN_L formalParameterList PAREN_R EOL blockOrForward
        {
            token t = $<chain>4;
            symbol_entry func = installSymbol(currentSymbolTable->parent, $<strVal>2, NULL, PROCEDURESYM);
            func->numParameters = lengthOf(t);
            func->innerScope = currentSymbolTable;
            int i = 0;
            while(t){
                symbol_entry s = findSymbol(currentSymbolTable, t->value, 0, BASICSYM);
                func->parameters[i] = s;
                i++;
                t = t->next;
            }
            printf("done");
            $<type>$ = NULL;
            retreat();
            
            //formalParameterList = list of tokens
            //add them all to the symbol table
            // add each symbol to the params array
            //retreat();
            
            }
        ;
blockOrForward:
    block 
    {
        reg("block or forward");
    }
    | FORWARD
    {
        
    }
    ;
    
block:  variableDeclarations compoundStatement
    {
        reg("block");
    }
;
paramDeclare:
    identifierList DECLARE type
    {
        token t = $<chain>1;
        while(t){
            
            installSymbol(currentSymbolTable, t->value, $<type>3, BASICSYM);
            
            t = t->next;
        }

        $<chain>$ = $<chain>1;
        //printTokenChain($<chain>$);
    }
    ;

paramList:
        paramList EOL paramDeclare
        {
            $<chain>$ = $<chain>1;
            token t = $<chain>1;
            while(t->next){t = t->next;}
            t->next = $<chain>3;
        }
        | paramDeclare 
        {$<chain>$ = $<chain>1;}
        ;
formalParameterList:
        paramList 
        {
            $<chain>$ = $<chain>1;
            reg("formalParameterList");
        }
        | /*empty*/
        {
            $<chain>$ = NULL;
        }
        ;

compoundStatement:
        BGN statementSequence endOfBlock
        {
            reg("compoundStatement");   
        }
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
            {
                reg("assignment");
                type_entry a = $<type>1;
                type_entry b = $<type>3;
                if(a != b){
                    printf("BOOM! type chash: %s does not match type %s\n", a->name, b->name);
                    yyerror("type clash");
                    YYERROR;
                }
                
            }
        ;
procedureStatement:
        ID PAREN_L actualParameterList PAREN_R
        {
            
            symbol_entry s = findSymbol(currentSymbolTable, $<strVal>1, 1, PROCEDURESYM);
            if(!s) s = findSymbol(currentSymbolTable, $<strVal>1, 1, FUNCTIONSYM);
            if(!s){
                printf("couldn't find procedure %s\n'", $<strVal>1 );
                yyerror("undeclared procedure called");
                YYERROR;
            }
            
            if(lengthOf($<chain>3) != s->numParameters){
                yyerror("wrong number of parameters");
                YYERROR;
            }
            token t = $<chain>3;
            int i = 0;
            for(i = 0; i < s->numParameters; i++){
                type_entry actual = resolveType(currentSymbolTable, t->value);
                type_entry declared = s->parameters[i]->type_pointer;
                if(actual != declared){
                    yyerror("procedure argument is of the wrong type");
                    YYERROR;
                }
                t = t->next;
            }
        }
        ;
apList:
        expression SEPARATOR apList
        {
            $<chain>$ = (token) malloc(sizeof(struct token_struct));
            $<chain>$->value = $<type>1->name;
            $<chain>$->next = $<chain>3;
        }
        | expression
        {
            $<chain>$ = (token) malloc(sizeof(struct token_struct));
            $<chain>$->value = $<type>1->name;
        }
        ;
actualParameterList:
        apList 
        {
            $<chain>$ = $<chain>1;
        }
        | /*empty*/
        {
            $<chain>$ = NULL;
        }
        ;
        
variable:
    ID componentSelection
    {
        // id
        // record.id
        // record[32].id
        // record.record.id
        $<type>$ = resolveStructuredType(currentSymbolTable, $<strVal>1, $<chain>2);
    }
    ;
componentSelection:
    STOP ID componentSelection
        {
            $<chain>$ = (token) malloc(sizeof(struct token_struct));
            $<chain>$->value = (char*)calloc(strlen($<strVal>2), sizeof(char));
            sprintf($<chain>$->value, "%s", $<strVal>2);
            $<chain>$->next = $<chain>3;
        }
    | ARRAY_L expression ARRAY_R componentSelection
        {
            if(strcmp($<type>2->name, "integer") != 0){
                yyerror("expression in array parens is not integer");
                YYERROR;
            }
            $<chain>$ = (token)malloc(sizeof(struct token_struct));
            $<chain>$->value = (char*)calloc(strlen("array"), sizeof(char));
            sprintf($<chain>$->value, "array");
        }
    | /*empty*/
    {$<chain>$ = NULL;}
    ;
expression:
    simpleExpression relationalOp simpleExpression
        {
            reg("expression");
            
            $<type>$ = $<type>1;
            if($<type>1 != $<type>3){
                yyerror("types don't match (expression)");
            }
            
            
            }
    | simpleExpression
        {
            reg("expression");
            $<type>$ = $<type>1;
            }
    ;
    
simpleExpression:
    sign term addOpTerm
        {
            reg("simpleExpression");
            $<type>$ = $<type>2;
            if($<type>3 && $<type>2 != $<type>3){
                yyerror("type mismatch (addOpTerm)");
            }            
        }
    ;
addOpTerm:
    addOp term addOpTerm
    {
        $<type>$ = $<type>2;
        if($<type>3 && $<type>2 != $<type>3){
            yyerror("type mismatch (addOpTerm)");
        }
    }
    | /*empty*/
    {$<type>$ = NULL;}
    ;
relationalOp:
    RELATIONAL | EQUALS
        {reg("relationalOp");}
    ;
mulOpFactor:
    mulOp factor mulOpFactor
    {
        $<type>$ = $<type>2;
        if($<type>3 && $<type>2 != $<type>3){
            yyerror("Incompatible types detected (mulOp factor mulOpFactor)");
            YYERROR;
        }
        
    }
    | /*empty*/
    {
        $<type>$ = NULL;
    }
    ;
term:
    factor mulOpFactor
        {
            reg("term");
            $<type>$ = $<type>1;
            if($<type>2 && $<type>1 != $<type>2){
                yyerror("Incompatible types detected (factor mulOpFactor)");
                YYERROR;
            }
        }
    ;
factorOptions:
    INT
    {
        $<type>$ = installNumber($<intVal>$)->type_pointer;
        
    } 
    | STRING_LITERAL
    {
        $<type>$ = resolveType(currentSymbolTable, "string");
    }
    | variable
    {
        $<type>$ = $<type>1;
    }
    | functionReference
    {
        reg("factorOptions (function)");
        $<type>$ = $<type>1;
    }
    | NOT factor
    {
        $<type>$ = $<type>2;
    } 
    | PAREN_L expression PAREN_R
    {
        $<type>$ = $<type>2;
    }
    ;
factor:
    factorOptions
        {
            reg("factor");
            $<type>$ = $<type>1;
        }
    ;
functionReference:
    ID PAREN_L actualParameterList PAREN_R
        {
            reg("functionReference");
            symbol_entry s = findSymbol(currentSymbolTable, $<strVal>1, 1, FUNCTIONSYM);
                  if(!s){
                      yyerror("undeclared function called");
                      YYERROR;
                  }
                  
                  if(lengthOf($<chain>3) != s->numParameters){
                      yyerror("wrong number of parameters");
                      YYERROR;
                  }
                  token t = $<chain>3;
                  int i = 0;
                  for(i = 0; i < s->numParameters; i++){
                      printf("function call checking on %s\n", t->value);
                      type_entry actual = resolveType(currentSymbolTable, t->value);
                      type_entry declared = s->parameters[i]->type_pointer;
                      if(actual != declared){
                          yyerror("procedure argument is of the wrong type");
                          YYERROR;
                      }
                      t = t->next;
                  }
                  $<type>$ = s->type_pointer;            
        }
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
            {   
                reg("typeDefinition");
                installSymbol(currentSymbolTable, $<strVal>1, $<type>3, BASICSYM);
             }
        ;

rec: RECORD
    {
        advance();
    }
;
type: ARRAY ARRAY_L INT RANGE INT ARRAY_R OF type
            {reg("type");
                $<type>$ = $<type>8;
                }
        | rec fieldList endOfBlock
            {
                
                reg("type");
                type_entry t = installType("record");
                t->scopedFields = currentSymbolTable;
                $<type>$ = t;
                retreat();
            }
        | ID
        {
            $<type>$ = resolveType(currentSymbolTable, $<strVal>1);
            if(!$<type>$){
                yyerror("type not found (type: ID)");
                YYERROR;
            }
            }
        ;

fieldList:
    paramDeclare EOL fieldList
    {   reg("fieldList");
        $<chain>$ = $<chain>1;
        token t = $<chain>1;
        while(t->next){t = t->next;}
        t->next = $<chain>3;
    }
    | paramDeclare
    {
        $<chain>$ = $<chain>1;
    }
    ;
endOfBlock:
    END
    {
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
    installType("integer");
    installType("string");
    type_entry t = installType("boolean");
    installSymbol(currentSymbolTable, "true", t, BASICSYM);
    installSymbol(currentSymbolTable, "false", t, BASICSYM);
    if ( argc == 0 ) exit(1);
            
    yyin = fopen( argv[0], "r" );

    int i = 0;

    yyparse();

    fclose(yyin);
    printf("printing symbol table to symtable.out\n");
//    printSymbolTables("symtable.out");
//    printParseTable("rules.out");
}



