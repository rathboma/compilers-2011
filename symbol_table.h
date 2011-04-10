//types table holds a list of all valid types. All symbol table entries must point to a valid type.
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct tentry * type_entry;
struct tentry{
    char* name;
    type_entry next;  
};

typedef struct s_entry * symbol_entry;
struct s_entry{
    char* symbol;
    type_entry type_pointer;
    symbol_entry next;
    };

typedef struct tbl_struct * table;
struct tbl_struct{
    symbol_entry head;
    table first_child;
    table next;
    table parent;
};


// actual tables
struct tbl_struct global_symbols = {0, 0, 0, 0};
struct tbl_struct number_table = {0, 0, 0, 0};
struct tentry type_table = {0, 0};

table currentSymbolTable = &global_symbols;

//type table methods

type_entry installType(char* name){
    type_entry s = &type_table;
    
    while(s->next) s = s->next;
    type_entry newt = (type_entry)malloc(sizeof(struct tentry));
    newt->name = calloc(strlen(name), sizeof(char));
    strcpy(newt->name, name);
    s->next = newt;
    return(newt);
}


type_entry resolveSymbolType(table t, char* name){
    symbol_entry s = t->head;
    while(s){
        if(strcmp(s->symbol, name) == 0) return(s->type_pointer);
        s = s->next;
    }
    if(t->parent) return resolveSymbolType(t->parent, name);
    return(NULL);
}

type_entry resolveType(table t, char* name){
    type_entry s = &type_table;
    while(s = s->next){
        // printf("comparing: %s, %s\n", name, s->name);
        if(strcmp(s->name, name) == 0) return(s);
    }
    return(resolveSymbolType(t, name));
}


// SYMBOL TABLE STUFF

symbol_entry findSymbol(table t, char* value, int searchParents){
    symbol_entry s = t->head;
    while(s){
        if(strcmp(s->symbol, value) == 0) return s;
        s = s->next;
    }
    if(searchParents && t->parent) return findSymbol(t->parent, value, searchParents);
    return(NULL);
}

symbol_entry installSymbol(table t, char* value, char* symbol_type)
{
    // 1. find the value in the current table
    // 2. if the value exists, throw an error
    // 3. if not, add an entry
    // 4. check if type is in the type table
    // 5. if not, search table and parents to resolve type
    // 6. if type resolved, add, otherwise, error
    
    
    //first see if the symbol already exists
    symbol_entry existing = findSymbol(t, value, 0);
    if(existing) {
        printf("symbol %s is already defined!\n", value);
        return(NULL);} //or throw an error somehow
    
    // resolve the type of the symbol
    type_entry new_type = resolveType(t, symbol_type);
    
    if(!new_type) {
        printf("the type %s cannot be resolved\n", symbol_type);
        return(NULL);
        }
    
    //create the new entry
    symbol_entry newEntry = (symbol_entry) malloc(sizeof(struct s_entry));
    newEntry->symbol = calloc(strlen(value), sizeof(char));
    strcpy(newEntry->symbol, value);
    newEntry->type_pointer = new_type;
    
    //find somewhere in the symbol table to put it
    symbol_entry parent = t->head;
    
    if(!parent) {t->head = newEntry;}
    else {
        while(parent->next){parent = parent->next;}
        parent->next = newEntry;
    }
    
    //return the new entry
    return(newEntry);
}


void advance(){
    table newt = malloc(sizeof(struct tbl_struct));
    newt->parent = currentSymbolTable;
    table sibling = currentSymbolTable->first_child;
    if(!sibling){
        currentSymbolTable->first_child = newt;
    }else{
        while(sibling = sibling->next){}
        sibling->next = newt;
    }
    currentSymbolTable = newt;
}

void retreat(){
    if(currentSymbolTable->parent) {currentSymbolTable = currentSymbolTable->parent;}
    else{printf("WARNING: retreat called, but already at the top of the symbol table tree\n");}
}

// types table
// methods:  resolveType(char* val) => returns type_entry / NULL
//          installType(char* val)

// symbol table
// methods:
//          installSymbol
//          resolveSymbol
//          addType(symbol, type)
//          







// structure:
// list of symbol_entries
// list of child symbol_tables
// parent table (if parent is self, then it is the global table, if null no children)
// 
// actions:
// install(token, lexeme, type)
//     token = CONSTANT
//     lexeme = STRING
//     type = STRING (looks it up in the type entry table)
// 
//     if token exists: throw error (already exists)
    