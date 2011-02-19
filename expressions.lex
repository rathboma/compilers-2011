/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
%}

ws		[ \t\n]+
char 	[A-Za-z_]
digit	[0-9]
comment_text [^{}]*
id		{char}({char}|{digit})*
integer	{digit}+
decimal	{digit}+(\.{digit}+)
number	[+-]?({integer}|{decimal})(E[+-]?{integer}+)?
relational "="|"<="|">="|"<>"
string_literal \"[^"]*\"
equals :=


%%

{number} 				{printf("Number: %s\n", yytext);}
{string_literal}				{printf("String Literal: %s\n", yytext);}
{relational}				{printf("Relational Operator: %s\n", yytext);}
{ws}					{/* do nothing */}
{id} 					{printf("Identifier: %s\n", yytext);}
"{"{comment_text}"}" 	{printf("comments: %s\n", yytext);}
.           			{printf( "Unrecognized character: '%s'\n", yytext );}
%%

main( argc, argv )
int argc;
char **argv;
    {
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;

    yylex();
    }
