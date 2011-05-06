//types table holds a list of all valid types. All symbol table entries must point to a valid type.
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>


void yyerror(char* message){
    printf("PARSER ERROR: %s\n", message);
    exit(1);
}
typedef struct node_struct * tree_node;
struct node_struct{
    char* value;
    char* addr;
    char* lop;
    char* rop;
    char* label;
    tree_node left;
    tree_node right;
    tree_node param;
    int type;
};
typedef struct token_struct * token;
struct token_struct{
    char* value;
    tree_node node;
    char* typeValue;
    token next;
};

token new_token(){
    token t = malloc(sizeof(struct token_struct));
    t->value = 0;
    t->next = 0;
    return t;
}

addToChain(token t, char* nextValue){
    while(t->next){ t = t->next;}
    t->next = (token) malloc(sizeof(struct token_struct));
    t->next->value = calloc(strlen(nextValue), sizeof(char));
    strcpy(t->next->value, nextValue);
}

lengthOf(token t){
    int i = 0;
    while(t){
        i++;
        t = t->next;
    }
    return i;
}



typedef struct tentry * type_entry;
typedef struct s_entry * symbol_entry;
typedef struct tbl_struct * table;
symbol_entry findSymbol(table, char*, int, int);

struct tentry{
    char* name;
    table scopedFields;
    type_entry next;
};
#define FUNCTIONSYM 1
#define PROCEDURESYM 2
#define BASICSYM 3



struct s_entry{
    char* symbol;
    int intVal;
    type_entry type_pointer;
    symbol_entry next;
    int numParameters;
    symbol_entry parameters[100];
    table innerScope;
    int symbolType;
    char * addr;
    char * label;
    };


struct tbl_struct{
    symbol_entry head;
    table parent;
};


// actual tables
struct tbl_struct global_symbols = {0, 0};
struct tbl_struct number_table = {0, 0};
struct tentry type_table = {0, 0, 0};

table currentSymbolTable = &global_symbols;

//stubs
void insert(table, symbol_entry);

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

type_entry findBaseType(char* name){
    //printf("looking for %s in base types\n", name);
    type_entry t = (&type_table)->next;
    while(t){
        //printf("checking %s\n", t->name);
        if(strcmp(name, t->name) == 0) return t;
        t = t->next;
    }
    yyerror("could not resolve base type");
    return NULL;
}


type_entry resolveSymbolType(table t, char* name, int checkParent){
    //printf("trying to resolve Type %s\n", name);
    symbol_entry s = t->head;
    while(s){
        if(strcmp(s->symbol, name) == 0) return(s->type_pointer);
        s = s->next;
    }
    if(checkParent && t->parent) return resolveSymbolType(t->parent, name, 1);
    printf("could not resolve %s to a type\n", name);
    yyerror("could not resolve to a type.");
    return(NULL);
}

type_entry resolveType(table t, char* name){
    type_entry s = &type_table;
    while(s = s->next){
        // //printf("comparing: %s, %s\n", name, s->name);
        if(strcmp(s->name, name) == 0) return(s);
    }
    return(resolveSymbolType(t, name, 1));
}

printTokenChain(token t){
    token t2 = t;
    while(t2){
        //printf("token: %s, ", t2->value);
        t2 = t2->next;
    }
}

type_entry resolveStructuredType(table t, char * name, token nesting){
    //printf("structured type looking for %s \n", name);
    
    symbol_entry parent = findSymbol(t, name, 1, BASICSYM);
    if(!parent){
        printf("%s not declared!\n", name);
        yyerror("variable not declared before use");
        
    }
    token tok = nesting;
    int depth = 0;
    type_entry target = parent->type_pointer;
    while(tok){
        if(strcmp("array", tok->value) == 0){
        }
        else{
            target = resolveSymbolType(target->scopedFields, tok->value, 0);
        }
        tok = tok->next;        
    }
    return(target);
}


// SYMBOL TABLE STUFF
symbol_entry findSymbol(table t, char* value, int searchParents, int symbolType){
    
    symbol_entry s = t->head;
    while(s){
        if(strcmp(s->symbol, value) == 0 && symbolType == s->symbolType) {
            return(s);
        }
        s = s->next;
    }

    if(searchParents && t->parent) {
    return findSymbol(t->parent, value, searchParents, symbolType);
    }
    return(NULL);
}

symbol_entry find(char* value, int symbolType){
    return findSymbol(currentSymbolTable, value, 1, symbolType);
}

symbol_entry installNumber(char* v){
    int value = atoi(v);
    symbol_entry entry = number_table.head;
    symbol_entry newt = malloc(sizeof(struct s_entry));
    if(!entry){
        number_table.head = newt;
    }else{
        while(entry->next){entry = entry->next;}
        entry->next = newt;
    }
    
    newt->intVal = value;
    newt->type_pointer = findBaseType("integer");
}

symbol_entry installSymbol(table t, char* value, type_entry theType, int symbolType)
{
    // 1. find the value in the current table
    // 2. if the value exists, throw an error
    // 3. if not, add an entry
    // 4. check if type is in the type table
    // 5. if not, search table and parents to resolve type
    // 6. if type resolved, add, otherwise, error
    
//    printf("installing symbol '%s' with type '%s'\n", value, theType ? theType->name : "(null)" );
    //first see if the symbol already exists
    symbol_entry existing = findSymbol(t, value, 0, symbolType);
    if(existing) {
        //printf("problem when installing symbol %s\n", value);
        yyerror("symbol is already defined!");
        return(NULL);
    } //or throw an error somehow
    // resolve the type of the symbol
    
    type_entry new_type = theType;
    
    //create the new entry
    symbol_entry newEntry = (symbol_entry) malloc(sizeof(struct s_entry));
    newEntry->addr = 0;
    newEntry->symbol = calloc(strlen(value), sizeof(char));
    strcpy(newEntry->symbol, value);
    newEntry->type_pointer = new_type;
    newEntry->symbolType = symbolType;
    
    insert(t, newEntry);
    //find somewhere in the symbol table to put it

}

void insert(table t, symbol_entry s){
    symbol_entry parent = t->head;
    if(!parent) {t->head = s;}
    else {
        while(parent->next){parent = parent->next;}
        parent->next = s;
    }    
    //return the new entry 
}


void advance(){
    table newt = malloc(sizeof(struct tbl_struct));
    //printf("advancing\n");
    newt->parent = currentSymbolTable;
    currentSymbolTable = newt;
}

void retreat(){
    //printf("retreating\n");
    if(currentSymbolTable->parent) {currentSymbolTable = currentSymbolTable->parent;}
    else{
        //printf("WARNING: retreat called, but already at the top of the symbol table tree\n");
        }
}

table new_table(){
    table t = (table) malloc(sizeof(struct tbl_struct));
    t->head = 0;
    t->parent = 0;
}

symbol_entry new_symbol(){
    return (symbol_entry)malloc(sizeof(struct s_entry));
}


// struct s_entry{
//     char* symbol;
//     int intVal;
//     type_entry type_pointer;
//     symbol_entry next;
//     int numParameters;
//     symbol_entry parameters[100];
//     table innerScope;
//     int symbolType;
//     char * addr;
//     };

void deep_symbol_copy(symbol_entry target, symbol_entry source){
    target->intVal = source->intVal;
    target->symbol = (char*) calloc(strlen(source->symbol), sizeof(char));
    strcpy(target->symbol, source->symbol);
    target->type_pointer = source->type_pointer;
    //skip the procedure related stuff and the inner scope stuff. Will be covered external to this.
    target->symbolType = source->symbolType;
    //different address!
}


void deep_table_copy(symbol_entry target, table source){
    if(!source) return;
    if(!target->innerScope) target->innerScope = new_table();
    symbol_entry s = source->head;
    while(s){
        symbol_entry ns = new_symbol();
        deep_symbol_copy(ns, s);
        deep_table_copy(ns, s->type_pointer->scopedFields);
        insert(target->innerScope, ns);
        s = s->next;
    }
    
}



char* get_value(token t){
    char* result;
    if(t->node){
        char* c = t->node->value ? t->node->value : t->node->addr;
        result = calloc(strlen(c) + 2, sizeof(char));
        sprintf(result, "[%s]", c);
    } else{
        char* c = t->value;
        result = calloc(strlen(c) + 1, sizeof(char));
        sprintf(result, ".%s", c);
    }

    return result;
}

char* component_string(token t){

    int totalLen = 0;
    int total = 0;
    token t2 = t;
    while(t2){
        totalLen += strlen(get_value(t2));
        if(t2->node) totalLen += 2;
        total++;
        t2 = t2->next;
    }
    char* result = calloc(totalLen + (total - 1), sizeof(char));
    t2 = t;
    strcpy(result, get_value(t2));
    t2 = t2->next;
    while(t2){sprintf(result, "%s%s", result, get_value(t2)); t2 = t2->next;}
    return result;
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
    