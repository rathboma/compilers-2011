%{
#include "lex.yy.c"
#include <math.h>
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
    wrapper details;
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
            token t = $<details>1->chain;
            while(t){
                symbol_entry s = installSymbol(currentSymbolTable, t->value, $<details>3->type, BASICSYM);
                deep_table_copy(s, $<details>3->type->scopedFields);
                t = t->next;
            }
        }
        ;
        
identifierList:
        ID multiIds
        {
            $<details>$ = new_wrapper(0, 0, 0);
            $<details>$->chain = (token) malloc(sizeof(struct token_struct));
            $<details>$->chain->value = calloc(strlen($<strVal>1), sizeof(char));
            strcpy($<details>$->chain->value, $<strVal>1 );
            $<details>$->chain->next = $<details>2->chain;
            reg("identifierList");
        }
        ;
multiIds: SEPARATOR identifierList
        {
            $<details>$ = $<details>2;

        }
        | /*empty*/
        {

            $<details>$ = new_wrapper(0, 0, 0);
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
            //printf("function.\n");
            token t = $<details>4->chain;
            strict_type_check($<details>7, $<details>9, "function declaration");
            printf("block type: %s\n", $<details>9->type->name);
            
            
            symbol_entry func = installSymbol(currentSymbolTable->parent, $<strVal>2, $<details>7->type, FUNCTIONSYM);
            //printf("installed symbol entry for function %s\n", func->symbol );
            func->label = calloc(strlen($<strVal>1), sizeof(char));
            strcpy(func->label, $<strVal>1);
            func->numParameters = lengthOf(t);
            //printf("number of parameters: %d\n", func->numParameters);
            func->innerScope = currentSymbolTable;
            int i = 0;
            while(t){

                symbol_entry s = findSymbol(currentSymbolTable, t->value, 0, BASICSYM);
                //printf("adding symbol entry to parameters list: %s\n", s->symbol );
                func->parameters[i] = s;
                i++;
                t = t->next;
            }
            $<details>$ = $<details>9;
            
            
            retreat();
            if($<details>9->node){
                char * result = calloc(strlen("funcreturn ") + strlen(value($<details>9->node)), sizeof(char));
                sprintf(result, "funcreturn %s", value($<details>9->node));
                soutput(result);
            }else{
                printf("function %s does not return correct type\n", $<strVal>2);
                yyerror("type clash!");
            }
            
            
            //formalParameterList = list of tokens
            //add them all to the symbol table
            // add each symbol to the params array
            //retreat();
            
        }
        ;
resultType:
    ID
    {
        $<details>$ = new_wrapper(0, resolveType(currentSymbolTable->parent, $<strVal>1), 0);
        printf("resultType type: %s\n", $<details>$->type->name);
        reg("resultType");
    }
    ;
func:
FUNC
{
    $<strVal>$ = label();
    soutput($<strVal>$);
    advance();
}
;
proc:
PROCEDURE
{
    $<strVal>$ = label();
    soutput($<strVal>$);
    advance();
}
;

procedureDeclaration:
        proc ID PAREN_L formalParameterList PAREN_R EOL blockOrForward
        {
            
            token t = $<details>4->chain;
            printf("proc declaration, name: %s\n", $<strVal>2);
            symbol_entry func = installSymbol(currentSymbolTable->parent, $<strVal>2, NULL, PROCEDURESYM);
            func->label = calloc(strlen($<strVal>1), sizeof(char));
            strcpy(func->label, $<strVal>1);
            func->numParameters = lengthOf(t);
            func->innerScope = currentSymbolTable;
            int i = 0;
            while(t){
                symbol_entry s = findSymbol(currentSymbolTable, t->value, 0, BASICSYM);
                func->parameters[i] = s;
                i++;
                t = t->next;
            }
            retreat();
            
            soutput("return");
            //formalParameterList = list of tokens
            //add them all to the symbol table
            // add each symbol to the params array
            //retreat();
            
            }
        ;
blockOrForward:
    block 
    {
        $<details>$ = $<details>1;
        reg("block or forward");
    }
    | FORWARD
    {
     $<details>$ = new_wrapper(0, 0, 0);   
    }
    ;
    
block:  variableDeclarations compoundStatement
    {
        $<details>$ = $<details>2;
        reg("block");
    }
;
paramDeclare:
    identifierList DECLARE type
    {
        token t = $<details>1->chain;
        while(t){
            
            installSymbol(currentSymbolTable, t->value, $<details>3->type, BASICSYM);
            t = t->next;
        }
        $<details>$ = $<details>1;
        //printTokenChain($<details>$->chain);
    }
    ;

paramList:
        paramList EOL paramDeclare
        {
            $<details>$ = $<details>1;
            token t = $<details>1->chain;
            while(t->next){t = t->next;}
            t->next = $<details>3->chain;
        }
        | paramDeclare 
        {$<details>$ = $<details>1;}
        ;
formalParameterList:
        paramList 
        {
            $<details>$ = $<details>1;
            reg("formalParameterList");
        }
        | /*empty*/
        {
            $<details>$ = new_wrapper(0, 0, 0);
        }
        ;

compoundStatement:
        BGN statementSequence endOfBlock
        {
            $<details>$ = $<details>2;
            reg("compoundStatement");   
        }
        ;

statementSequence:
        statement EOL statementSequence
        {
            printf("statement sequence: %s\n", $<details>$->type->name);
            $<details>$ = $<details>3;
            if(!$<details>3->type) $<details>$ = $<details>1;
            reg("statementSequence");}
        | statement
        {
            $<details>$ = $<details>1;
            reg("statementSequence");}
        ;
statement:
    open
    {
        $<details>$ = $<details>1;
        reg("statement");
        }
    | matched
    {
        $<details>$ = $<details>1;

        reg("statement");
    }
    ;

otherStatements:
    compoundStatement
    {
        $<details>$ = $<details>1;
        reg("structuredStatement");}
    | simpleStatement
    {
        $<details>$ = $<details>1;
        reg("simpleStatement");}
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
        {
            $<details>$ = new_wrapper(0, 0, 0);
            reg("structuredStatement");}
    | otherStatements
        {
            $<details>$ = $<details>1;
            reg("structuredStatement");}
    | loopHeader matched
        {
            $<details>$ = new_wrapper(0, 0, 0);
            reg("structuredStatement");}
    ;


simpleStatement:
    assignmentStatement
    {
        $<details>$ = $<details>1;
        
    }
    | procedureStatement
    {
        $<details>$ = $<details>1;
    }
    | /*empty*/
    {$<details>$ = new_wrapper(0, 0, 0);}
    ;
assignmentStatement:
        variable ASSIGNMENT expression
            {
                reg("assignment");
                type_check($<details>1, $<details>3, "assignment statment");
                
                $<details>$ = new_wrapper(0, 0, new_nodea());
                $<details>$->node->left = $<details>1->node; 
                $<details>$->node->right = $<details>3->node;
                $<details>$->chain = new_token();
                $<details>$->type = $<details>1->type;
                setops($<details>$->node, ":=", "");
                output($<details>$->node);
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
            
            if(lengthOf($<details>3->chain) != s->numParameters){
                yyerror("wrong number of parameters");
                YYERROR;
            }
            token t = $<details>3->chain;
            int i = 0;
            for(i = 0; i < s->numParameters; i++){
                type_entry actual = resolveType(currentSymbolTable, t->typeValue);
                char * statement = calloc(strlen("param ") + strlen(t->value), sizeof(char));
                sprintf(statement, "%s%s", "param ", t->value);
                soutput(statement);
                type_entry declared = s->parameters[i]->type_pointer;
                if(actual != declared){
                    yyerror("procedure argument is of the wrong type");
                    YYERROR;
                }
                t = t->next;
            }
            char result[100];
            sprintf(result, "call %s", $<strVal>1);
            soutput(result);
        }
        ;
apList:
        expression SEPARATOR apList
        {
            if($<details>1->node->type != LEAF) output($<details>1->node);
            $<details>$ = new_wrapper(new_token(), 0, 0);
            $<details>$->chain->typeValue = $<details>1->type->name;
            $<details>$->chain->value = $<details>1->node->type == LEAF ? $<details>1->node->value : $<details>1->node->addr;
            $<details>$->chain->next = $<details>3->chain;
        }
        | expression
        {
            if($<details>1->node->type != LEAF) output($<details>1->node);
            $<details>$ = new_wrapper(new_token(), 0, 0);
            $<details>$->chain->typeValue = $<details>1->type->name;
            $<details>$->chain->value = $<details>1->node->type == LEAF ? $<details>1->node->value : $<details>1->node->addr;
        }
        ;
actualParameterList:
        apList 
        {
            $<details>$ = $<details>1;
        }
        | /*empty*/
        {
            $<details>$ = new_wrapper(0, 0, 0);
        }
        ;
        
variable:
    ID componentSelection
    {
        // id
        // record.id
        // record[32].id
        // record.record.id
        symbol_entry sym = find($<strVal>1, BASICSYM);
        $<details>$ = new_wrapper(0, resolveStructuredType(currentSymbolTable, $<strVal>1, $<details>2->chain), 0 );
        //printf("variable '%s', type: %s\n", $<strVal>1, $<details>$->type->name);
        //assuming just ID
        
        token component = $<details>2 ? $<details>2->chain : NULL;
        
        $<details>$->node = leaf_for_sym(sym);
        // for each component
        //  
        if(component){
            char * componentChain = component_string(component);
            char* adr = addr(sym);
            $<details>$->node->addr = calloc(strlen(adr) + strlen(componentChain) + 1, sizeof(char));
            sprintf($<details>$->node->addr, "%s%s", adr, componentChain);
        }
        
        
        
/*        while(component){
            sym = findSymbol(sym->innerScope, component->value, 0, BASICSYM);
            component = component->next;
        }*/
        
/*                //ignores arrays for now though...
                tree_node current_node = leaf_for_sym(sym);
                symbol_entry previous_symbol = sym;
                while(component){
                    //printf("looking for %s in inner scope of %s\n", component->value, $<strVal>1);
                    
                    //printf("got component symbol\n");
                    tree_node nn = new_nodea();
                    
                    symbol_entry component_symbol;
                    if(strcmp(component->value, "array") == 0){
                        setops(nn, "[", "]");
                        nn->right = component->node;
                        printf("array found, right node value / address: %s / %s\n", component->node->value, component->node->addr);
                        component_symbol = previous_symbol;
                    }
                    else{
                        component_symbol = findSymbol(previous_symbol->innerScope, component->value, 0, BASICSYM);
                        setops(nn, ".", "");
                        nn->right = leaf_for_sym(component_symbol);
                    }
                    nn->left = current_node;
                    current_node = nn;
                    previous_symbol = component_symbol;
                    component = component->next;
                }
                $<details>$->node = current_node;
*/                
    }
    ;
componentSelection:
    STOP ID componentSelection
        {
            $<details>$ = new_wrapper(new_token(), 0, 0);
            $<details>$->chain->value = calloc(strlen($<strVal>2), sizeof(char));
            strcpy($<details>$->chain->value, $<strVal>2);
            $<details>$->chain->next = $<details>3->chain;
            
        }
    | ARRAY_L expression ARRAY_R componentSelection
        {
            if(strcmp($<details>2->type->name, "integer") != 0){
                yyerror("expression in array parens is not integer");
                YYERROR;
            }
            $<details>$ = new_wrapper(new_token(), 0, 0);
            $<details>$->chain->value = calloc(strlen("array"), sizeof(char));
            strcpy($<details>$->chain->value, "array");
            $<details>$->chain->node = $<details>2->node;
            if($<details>$->chain->node->type != LEAF) output($<details>$->chain->node);
            
            $<details>$->chain->next = $<details>4->chain;
        }
    | /*empty*/
    {$<details>$ = new_wrapper(0, 0, 0);}
    ;
    
/*    a = b | a < b | a + b <= c*d-4  */
expression:
    simpleExpression relationalOp simpleExpression
        {
            reg("expression");
            $<details>$ = $<details>1;

            if($<details>1->type != $<details>3->type){
                yyerror("types don't match (expression)");
            }
            $<details>$->node = new_node();
            setops($<details>$->node, $<strVal>2, "");
            $<details>$->node->left = $<details>1->node;
            $<details>$->node->right = $<details>3->node; 
            }
    | simpleExpression
        {
            reg("expression");
            //printf("simpleExpression type: %s\n", $<details>1->type->name);
            $<details>$ = $<details>1;
            }
    ;
    
sign:
    ADDOP {reg("sign"); $<strVal>$ = $<strVal>1;} | /*empty*/ {$<strVal>$ = 0;}
    ;
/*  - b | -b + 3 | a*b+c/d */
simpleExpression:
    sign term addOpTerm
        {
            reg("simpleExpression");
            
            if($<details>3->type) type_check($<details>3, $<details>2, "simpleExpression");
            tree_node current;
            
            //IGNORING the sign for now
            
            tree_node term = $<details>2->node;
            
            if($<details>3->node){
                tree_node t = $<details>3->node;
                while(t->left){t = t->left;}
                t->left = term;
                $<details>$ = $<details>3;
            } else {
                $<details>$ = $<details>2;
            }
            $<details>$->type = $<details>2->type;
            
            


            
        }
    ;
addOpTerm:
    addOp term addOpTerm
    {
        type_check($<details>3, $<details>2, "addopterm");
        
        $<details>$ = new_wrapper($<details>2->chain, $<details>2->type, new_nodea());
        setops($<details>$->node, $<strVal>1, "");
        tree_node three = $<details>3->node;
        if(three){
            $<details>$->node->right = three;
            three->left = $<details>2->node;
        }
        else {$<details>$->node->right = $<details>2->node;}
        
    }
    | /*empty*/
    {$<details>$ = new_wrapper(0, 0, 0);}
    ;
relationalOp:
    RELATIONAL 
        {
            reg("relationalOp");
            $<strVal>$ = $<strVal>1;
        }
    | EQUALS
        {
            reg("relationalOp");
            $<strVal>$ = $<strVal>1;
        }
    ;
    /* *a | *a div b    */
mulOpFactor:
    mulOp factor mulOpFactor
    {
        type_check($<details>3, $<details>2, "mulOpFactor");
        
        $<details>$ = new_wrapper($<details>2->chain, $<details>2->type, new_nodea());
        setops($<details>$->node, $<strVal>1, "");
        tree_node three = $<details>3->node;
        if(three){
            $<details>$->node->right = three;
            three->left = $<details>2->node;
        }
        else {$<details>$->node->right = $<details>2->node;}
    }
    | /*empty*/
    {
        $<details>$ = new_wrapper(0, 0, 0);
    }
    ;
term:
    factor mulOpFactor
        {
            reg("term");
            if($<details>2->type) type_check($<details>2, $<details>1, "term");
            tree_node mulop = $<details>2->node;
            if(mulop){
                $<details>$ = $<details>2;
                mulop->left = $<details>1->node;
            } else{
                $<details>$ = $<details>1;
            }
        }
    ;
factor:
    factorOptions
        {
            reg("factor");
            //printf("factor type: %s, node: %s\n", $<details>1->type->name, $<details>1->node->value ? $<details>1->node->value : $<details>1->node->addr);
            $<details>$ = $<details>1;
            
        }
    ;
factorOptions:
    INT
    {
        $<details>$ = new_wrapper(0,installNumber($<strVal>1)->type_pointer, new_node());
//        printf("found int! %s\n", $<strVal>1);
        leaf($<details>$->node, $<strVal>1);
        
    } 
    | STRING_LITERAL
    {
        $<details>$ = new_wrapper(0, findBaseType("string"), new_node());
        leaf($<details>$->node, $<strVal>1);
        
        //printf("resolving string literal\n");
    }
    | variable
    {
        $<details>$ = $<details>1;
    }
    | functionReference
    {
        reg("factorOptions (function)");
        $<details>$ = $<details>1;
    }
    | NOT factor
    {
        $<details>$ = $<details>2;
        printf("WARNING: not assigning node, NOT factor\n");
    } 
    | PAREN_L expression PAREN_R
    {
        $<details>$ = $<details>2;
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
                  
                  if(lengthOf($<details>3->chain) != s->numParameters){
                      yyerror("wrong number of parameters");
                      YYERROR;
                  }
                  token t = $<details>3->chain;
                  int i = 0;
                  for(i = 0; i < s->numParameters; i++){
                      type_entry actual = resolveType(currentSymbolTable, t->typeValue);
                      char * statement = calloc(strlen("param ") + strlen(t->value), sizeof(char));
                      sprintf(statement, "%s%s", "param ", t->value);
                      soutput(statement);
                      type_entry declared = s->parameters[i]->type_pointer;
                      if(actual != declared){
                          yyerror("procedure argument is of the wrong type");
                          YYERROR;
                      }
                      t = t->next;
                  }
                  $<details>$ = new_wrapper(0, s->type_pointer, new_node());
                  tree_node n = $<details>$->node;
                  n->type = LEAF;
                  n->value = calloc(strlen("funcall ") + strlen(s->label) + 3 + strlen($<strVal>1), sizeof(char));
                  sprintf(n->value, "funcall %s (%s)", $<strVal>1, s->label);
        }
    ;


addOp:
    ADDOP 
        {reg("addOp"); $<strVal>$ = $<strVal>1;}
    | OR
        {reg("addOp"); $<strVal>$ = $<strVal>1;}
    ;
mulOp:
    MULTIOP 
        {reg("mulOp");}
    | MOD 
        {reg("mulOp");}
    | AND
        {reg("mulOp");}
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
                installSymbol(currentSymbolTable, $<strVal>1, $<details>3->type, BASICSYM);
                
             }
        ;

rec: RECORD
    {
        advance();
    }
;
type: ARRAY ARRAY_L INT RANGE INT ARRAY_R OF type
            {
                reg("type");
                $<details>$ = $<details>8;
            }
        | rec fieldList endOfBlock
            {
                
                reg("type");
                type_entry t = installType("record");
                t->scopedFields = currentSymbolTable;
                $<details>$ = new_wrapper(0, t, 0);
                retreat();
            }
        | ID
        {
            $<details>$ = new_wrapper(0, resolveType(currentSymbolTable, $<strVal>1), 0 );
            if(!$<details>$->type){
                yyerror("type not found (type: ID)");
                YYERROR;
            }
            }
        ;

fieldList:
    paramDeclare EOL fieldList
    {   reg("fieldList");
        $<details>$ = $<details>1;
        token t = $<details>1->chain;
        while(t->next){t = t->next;}
        t->next = $<details>3->chain;
    }
    | paramDeclare
    {
        $<details>$ = $<details>1;
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
    //printf("printing symbol table to symtable.out\n");
//    printSymbolTables("symtable.out");
//    printParseTable("rules.out");
}



