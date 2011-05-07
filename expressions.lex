/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>
// code_tree includes symbol table
#include "wrapper.h"
#include "shared.h"
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
int             [+-]?{integer}
float			[+-]?{decimal}(E{int}+)?
string_literal 	\"[^"]*\"
relop           "<"|">"|"<="|">="|"<>"


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
"or"        {
                yylval.strVal = calloc(strlen(yytext), sizeof(char));
                strcpy(yylval.strVal, yytext);
                return(OR);
            }
"procedure" {return(PROCEDURE);}
"program"   {return(PROGRAM);}
"record"    {return(RECORD);}
"then"      {return(THEN);}
"to"        {return(TO);}
"type"      {return(TYPE);}
"var"       {return(VAR);}
"while"     {return(WHILE);}

"+"|"-"         {
                    yylval.strVal = calloc(strlen(yytext), sizeof(char));
                    strcpy(yylval.strVal, yytext);
                    return(ADDOP);
                }
                
"*"|"div"       {
                    yylval.strVal = calloc(strlen(yytext), sizeof(char));
                    strcpy(yylval.strVal, yytext);
                    return(MULTIOP);
                }

"="             {   yylval.strVal = calloc(strlen(yytext), sizeof(char));
                    strcpy(yylval.strVal, yytext); 
                    return(EQUALS);
                }
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
  
{relop}         {
                    yylval.strVal = calloc(strlen(yytext), sizeof(char)); 
                    strcpy(yylval.strVal, yytext); 
                    return(RELATIONAL);
                    }

{ws}|{comment}      {/* do nothing*/}
{id}                {
                        yylval.strVal = calloc(strlen(yytext), sizeof(char));
                        strcpy(yylval.strVal, yytext);
                        //printf("lexed id: '%s'\n", yylval.strVal); 
                        return(ID);
                        }
{int}               {
        //printf("found int (lex) %s\n", yytext);
        yylval.strVal = calloc(strlen(yytext), sizeof(char));
        strcpy(yylval.strVal, yytext);
        return(INT);
    }
{float}            {yylval.doubleVal = atof(yytext); return(FLOAT);}
{string_literal}    {
                        yylval.strVal = calloc(strlen(yytext), sizeof(char));
                        strcpy(yylval.strVal, yytext);
                        return(STRING_LITERAL);
                    }

%%



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
