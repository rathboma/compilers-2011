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


void type_check(wrapper a, wrapper b){
    if(a->type && b->type && a->type != b->type){
        yyerror("Incompatible types detected (factor mulOpFactor)");
    }
    
}