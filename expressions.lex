/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>
#include "translate.tab.h"
// SYMBOL DECLARATIONS
// and begin forward div do else end for function if array mod not of 
//    or procedure program record then to type var while + * -  = < <= > 
//    >= <> . , : ; := .. ( ) [ ]

//MOVING TOKENS TO THE BISON FILE
%}


ws				[ \t\n]+
char 			[A-Za-z_]
digit			[0-9]
integer			{digit}+
decimal			{digit}+(\.{digit}+)

comment 	    "{"[^{}]*"}"
id				{char}({char}|{digit})*
number			[+-]?({integer}|{decimal})(E[+-]?{integer}+)?
string_literal 	\"[^"]*\"


%%
"and"       {return(AND);}
"begin"     {return(BGN);}
"forward"   {return(FORWARD);}
"div"       {return(DIV);}
"do"        {return(DO);}
"else"      {return(ELSE);}
"end"       {return(END);}
"for"       {return(FOR);}
"function"  {return(FUNC);}
"if"        {return(IF);}
"array"     {return(ARRAY);}
"mod"       {return(MOD);}
"not"       {return(NOT);}
"of"        {return(OF);}
"or"        {return(OR);}
"procedure" {return(PROCEDURE);}
"program"   {return(PROGRAM);}
"record"    {return(RECORD);}
"then"      {return(THEN);}
"to"        {return(TO);}
"type"      {return(TYPE);}
"var"       {return(VAR);}
"while"     {return(WHILE);}

"+"|"-"|"*"|"/" {return(MATH);}
"="|"<="|">="|"<>"  {return(RELATIONAL);}
"."                 {return(STOP);} 
","                 {return(SEPARATOR);} 
":"                 {return(DECLARE);} 
";"                 {return(EOL);} 
":="                {return(ASSIGNMENT);} 
".."                {return(RANGE);} 
"("                 {return(PAREN_L);} 
")"                 {return(PAREN_R);} 
"["                 {return(ARRAY_L);} 
"]"                 {return(ARRAY_R);}


{ws}|{comment}      {/* do nothing*/}
{id}                {yylval = yytext; installID(); return(ID);}
{number}            {yylval = yytext; installNum(); return(NUMBER);}
{string_literal}    {yylval = yytext; return(STRING_LITERAL);}

%%

typedef struct s_entry * symbol_entry;

struct s_entry{
    char *symbol;
    symbol_entry next;
    };

struct s_entry symboltable = {0, 0};
struct s_entry numbertable = {0, 0};

int install(symbol_entry table)
{
    symbol_entry s = table;
    while(s->next){
        s = s->next;
        if(strcmp(s->symbol, yytext) == 0){
            // printf("symbol already found %s\n", yytext);
            return((long)s);
        }
    }
    symbol_entry new_s = (symbol_entry) malloc(sizeof(struct s_entry));
    int length = 0;
    new_s->symbol = (char*)malloc(sizeof(yytext));
    strcpy(new_s->symbol, yytext);
    new_s->next = NULL;
    s->next = new_s;
    // printf("inserted symbol %s\n", new_s->symbol);
    return((long)new_s);
}


int installID(){
    // printf("starting installID\n");
    install(&symboltable);
}

int installNum(){
    install(&numbertable);
}

void printSymbolTable(symbol_entry table){
    
    symbol_entry s = table->next;
    while(s){
        printf("entry: %s\n", s->symbol);
        s = s->next;
    }
    
    
}


// main( argc, argv )
// int argc;
// char **argv;
//     {
//     ++argv, --argc;  /* skip over program name */
//     if ( argc > 0 )
//             yyin = fopen( argv[0], "r" );
//     else
//             yyin = stdin;
//     int i = 0;
//     while(i = yylex()){
//         printf("found token '%s', token constant %d\n", yytext, i);
//     }
//     printf("printing symbol table\n");
//     printSymbolTable(&symboltable);
//     printf("printing number table\n");
//     printSymbolTable(&numbertable);
//     }
