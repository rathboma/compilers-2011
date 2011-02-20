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
#define REORD 17
#define THEN 18
#define TO 19
#define TYPE 20
#define VAR 21
#define WHILE 22
#define ARITHMETIC 23
#define RELATIONAL 24 // < <= > >=
#define STOP 25 // .
#define SEPARATOR 26 // ,
#define DECLARATION 27 // :
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



%}

ws				[ \t\n]+
char 			[A-Za-z_]
digit			[0-9]
comment 	    "{"[^{}]*"}"
id				{char}({char}|{digit})*
integer			{digit}+
decimal			{digit}+(\.{digit}+)
number			[+-]?({integer}|{decimal})(E[+-]?{integer}+)?
relational 		"="|"<="|">="|"<>"
string_literal 	\"[^"]*\"
equals 			:=
arithmetic 		"+"|"-"|"*"|"/"
line_terminator ";"
declaration		":"
paren_l			"("
paren_r			")"
list_separator	","
range_spec		".."
array_l			"["
array_r			"]"

%%
{id}    {printf("found id\n"); installID(); return(ID);}
.       {/* do nothing! (testing) */}
%%

typedef struct symbol_entry * symbol_entry;
typedef struct number_entry * number_entry;
struct symbol_entry{
    char *symbol;
    struct symbol_entry *next;  
};
struct number_entry{
    float number;
    struct number_entry *next;
};


struct symbol_entry symboltable = {0, 0};

int installID(){
    printf("starting installID\n");
    symbol_entry s = &symboltable;
    while(s->next){
        s = s->next;
        if(strcmp(s->symbol, yytext) == 0){
            printf("symbol already found %s\n", yytext);
            return((int) s);
        }
    }
    symbol_entry new_s = (symbol_entry) malloc(sizeof(struct symbol_entry));
    s->symbol = (char*) malloc(sizeof(*yytext));
    strcpy(s->symbol, yytext);
    new_s->next = NULL;
    s->next = new_s;
    printf("inserted symbol %s\n", yytext);
    return (int) new_s;
}

void printSymbolTable(){
    symbol_entry s = &symboltable;
    while(s->next){
        printf("symbol table entry: %s\n", s->symbol);
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

    while(yylex()){
        
    }
    printf("printing symbol table\n");
    printSymbolTable();
    
    }
