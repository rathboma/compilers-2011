#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "code_tree.h"

typedef struct lexwrapper * wrapper;
struct lexwrapper{
    token chain;
    tree_node node;
    type_entry type;
};

wrapper new_wrapper(token c, type_entry t, tree_node n){
    wrapper w = malloc(sizeof(struct lexwrapper));
    w->chain = c;
    w->node = n;
    w->type = t;
    return w;
}


void type_check(wrapper a, wrapper b, char* caller){
    if(a->type && b->type && a->type != b->type){
        printf("error in %s\n", caller);
        yyerror("type chash!");
    }
    
}
void strict_type_check(wrapper a, wrapper b, char* caller){
    if(!a->type || !b->type || a->type != b->type){
        printf("error in %s: %s vs %s\n", caller, (a->type && a->type->name ? a->type->name : "(null)"), (b->type && b->type->name ? b->type->name : "(null)"));
        yyerror("type chash!");
    }
    
}