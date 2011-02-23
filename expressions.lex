/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <string.h>
// SYMBOL DECLARATIONS
// and begin forward div do else end for function if array mod not of 
//    or procedure program record then to type var while + * -  = < <= > 
//    >= <> . , : ; := .. ( ) [ ]
#define AND		0
#define BGN 1
#define FORWARD 2
#define DIV 3
#define DO 4
#define ELSE 5
#define END 6
#define FOR 7
#define FUNC 8
#define IF 9
#define ARRAY 10
#define MOD 11
#define NOT 12
#define OF 13
#define OR 14
#define PROCEDURE 15
#define PROGRAM 16
#define RECORD 17
#define THEN 18
#define TO 19
#define TYPE 20
#define VAR 21
#define WHILE 22
#define MATH 23
#define RELATIONAL 24 // < <= > >=
#define STOP 25 // .
#define SEPARATOR 26 // ,
#define DECLARE 27 // :
#define EOL 28 // ;
#define ASSIGNMENT 29 // :=
#define RANGE 30
#define PAREN_L 31
#define PAREN_R 32
#define ARRAY_L 33
#define ARRAY_R 34
// COMPLICATED STUFF
#define NUMBER 35
#define ID 36
#define STRING_LITERAL 37
// wow, thats a lot of stuff.
#define UNRECOG 9999


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
{id}                {installID(); return(ID);}
{number}            {installNum(); return(NUMBER);}
{string_literal}    {return(STRING_LITERAL);}

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
    
    symbol_entry s = table;
    while(s){
        printf("entry: %s\n", s->symbol);
        s = s->next;
    }
    
    
}


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
    while(i = yylex()){
        printf("found token '%s', token constant %d\n", yytext, i);
    }
    printf("printing symbol table\n");
    printSymbolTable(&symboltable);
    printf("printing number table\n");
    printSymbolTable(&numbertable);
    }
