#include <string.h>
#include <math.h>
#include <stdio.h>

typedef struct s_entry * symbol_entry;

struct s_entry{
    char* symbol;
    char* type;
    symbol_entry next;
    };

struct s_entry symboltable = {0, 0, 0};
struct s_entry numbertable = {0, 0, 0};
struct s_entry parsetable = {0, 0, 0};
FILE* parsefile;
symbol_entry findEntry(symbol_entry table, char* value){
    symbol_entry s = table;
    while(s->next){
        s = s->next;
        if(strcmp(s->symbol, value) == 0){
            //printf("symbol found %s\n", value);
            return(s);
        }
    }
    return(NULL);
}



symbol_entry install(symbol_entry table, char* value)
{
    symbol_entry s = findEntry(table, value);
    if(s) return(s);
    
    //else we haven't found it.
    
    symbol_entry new_s = (symbol_entry) malloc(sizeof(struct s_entry));
    new_s->symbol = (char*)malloc(sizeof(value));
    strcpy(new_s->symbol, value);
    new_s->next = table->next;
    table->next = new_s;
    // printf("inserted symbol %s\n", new_s->symbol);
    return(new_s);
}

void chainValue(symbol_entry t, char* v){
    symbol_entry s = t;
    while(s->next){
        s = s->next;
    }
    
    symbol_entry ns = (symbol_entry) malloc(sizeof(struct s_entry));
    ns->symbol = (char*)malloc(sizeof(v));
    strcpy(ns->symbol, v);
    s->next = ns;
}


symbol_entry installID(){
    // printf("starting installID\n");
    install(&symboltable, yytext);
}

symbol_entry installNum(){
    install(&numbertable, yytext);
}

void updateSymbolTable(char* key, char* type){
    symbol_entry s = findEntry(&symboltable, key);
    s->type = (char*)malloc(sizeof(type));
    strcpy(s->type, type);
}

void printSymbolTables(char* filename){
    FILE* file;
    file = fopen(filename, "w");
    symbol_entry s = symboltable.next;
    while(s){
        fprintf(file, "%s %s\n", s->symbol, s->type ? s->type : "");
        s = s->next;
    }
    s = numbertable.next;
    while(s){
        fprintf(file, "%s\n", s->symbol);        
        s = s->next;
    }
    fclose(file);
    printf("I have just written the symbol table.\n");    
}


void printParseTable(char* filename){
    FILE* file;
    file = fopen(filename, "w");
    symbol_entry s = parsetable.next;
    while(s){
        //for some reason these strings are now messed up. I have NO idea why.
        fprintf(file, "%s\n", s->symbol);
        s = s->next;
    }
    fclose(file);
    printf("I have just written the parse table.\n");
}

void reg(char* rule){
    fprintf(parsefile, "%s\n", rule);
    //for some reason, keeping these in a linked list causes weird problems with null termination. for not just
    // dump straight to the file.
    //chainValue(&parsetable, rule);
}


