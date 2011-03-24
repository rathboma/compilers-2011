#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
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

void updateSymbolTable(char* key, char* t){
    printf("updating: %s with %s\n", key, t);
    symbol_entry s = findEntry(&symboltable, key);
    s->type = (char*)malloc(sizeof(t));
    sprintf(s->type, "%s", t);
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

int getlength(symbol_entry s){
    int result = 0;
    while(s){
        result = result + 1;
        s = s->next;
    }
    return result;
}

char* join(symbol_entry s){
    int total = 0;
    symbol_entry si = s;
    if(!s) return NULL;
    while(si){
        total += sizeof(si->symbol);
        si = si->next;
    }
    char* result = malloc(total + getlength(s)); //assuming a character is 1 byte... bit hacky
    si = s->next;
    sprintf(result, "%s", s->symbol);
    while(si){
        sprintf(result, "%s,%s", result, si->symbol);
        si = si->next;
    }
    return result;
}


void updateAll(symbol_entry s, char* type){
    symbol_entry si = s;
    while(si){
        printf("updateAll: %s\n", si->symbol);
        updateSymbolTable(si->symbol, type);
        si = si->next;
    }
}