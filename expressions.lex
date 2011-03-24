/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>
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
"<="|">="|"<>"  {return(RELATIONAL);}
"="             {return(EQUALS);}
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
{id}                {yylval.table = installID(); return(ID);}
{int}               {yylval.table = installNum(); return(INT);}
{float}            {yylval.table = installNum(); return(FLOAT);}
{string_literal}    {yylval.strVal = yytext; return(STRING_LITERAL);}

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
