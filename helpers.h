#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void yyerror(char* message){
    printf("%s\n", message);
    exit(1);
}

typedef token_struct * token;
struct token_struct{
    char* value;
    token next;
}

void addToChain(token t, char* nextValue){
    while(t->next){ t = t->next;}
    t->next = (token) malloc(sizeof(struct token_struct));
    t->next->value = calloc(strlen(nextValue), sizeof(char));
    strcpy(t->next->value, nextValue);
}

char * stringify_params(token tok, char* tpe){
    int length = 0;
    token t = tok;
    while(t){length += strlen(t->value); t = t->next;}
    char* result = calloc(length + 1, sizeof(char));
    t = tok;
    while(t){sprintf(result, "%s%s", result, t->value); t = t->next;}
    return(result);
}