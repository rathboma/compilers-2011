#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"



#define LEAF 1
#define NODE 2






char current_prefix = 'a';
int current_num = 0;
int label_num = 0;
char label_prefix = 'a';
tree_node setaddr(tree_node, char*);


char * label(){
    
    //printf("returning: prefix: %c, current num: %d\n", current_prefix, current_num);
    char * result = (char*) calloc(2 + strlen("label"), sizeof(char));
    sprintf(result, "label%c%d", label_prefix, label_num);
    label_num = (label_num + 1) % 10;
    if(label_num == 0) label_prefix++;
    return(result);
}




char * gen_address(){
    
    //printf("returning: prefix: %c, current num: %d\n", current_prefix, current_num);
    char * result = (char*) calloc(2, sizeof(char));
    sprintf(result, "%c%d", current_prefix, current_num);
    current_num = (current_num + 1) % 10;
    if(current_num == 0) current_prefix++;
    return(result);
}

char* addr(symbol_entry s){
    if(!s->addr) {
        s->addr = s->symbol;
    }
    return s->addr;
}

tree_node new_node(){
    tree_node basic = ((tree_node)malloc(sizeof(struct node_struct)));
    basic->type = NODE;
    return basic;
}
tree_node new_nodea(){
    tree_node n = new_node();
    n->addr = gen_address();
    return n;
}

tree_node leaf_for(char* val, int sym_type){
    symbol_entry s = find(val, sym_type);
    tree_node n = new_node();
    n->type = LEAF;
    setaddr(n, addr(s));  
    return n;
}

tree_node leaf_for_sym(symbol_entry s){
    tree_node n = new_node();
    n->type = LEAF;
    setaddr(n, addr(s));
    return n;
}

tree_node setaddr(tree_node n, char* addr){
    n->addr = calloc(strlen(addr), sizeof(char));
    strcpy(n->addr, addr);
    return n;
}

void setops(tree_node n, char* op, char* op2){
    n->lop = (char*) calloc(strlen(op), sizeof(char));
    strcpy(n->lop, op);
    n->rop = (char*) calloc(strlen(op2), sizeof(char));
    strcpy(n->rop, op2);
}


tree_node leaf(tree_node n, char* val){
    n->value = (char*)calloc(strlen(val), sizeof(char));
    strcpy(n->value, val);
    n->type = LEAF;
    n->left = NULL;
    n->right = NULL;
    return n;
}

void soutput(char* s){
    printf("%s\n", s);
}
FILE *output_file;
void output(tree_node n){
    if(!n) return;
    //printf("output called for node. leaf? %c, addr|val: %s|%s, l/r: %c/%c\n", (n->type == LEAF) ? 't' : 'f', n->addr, n->value, n->left ? 't' : 'f', n->right ? 't' : 'f');
    if(n->label) fprintf(output_file, "%s:\n", n->label);
    if(n->type == LEAF) return;
    output(n->left);
    output(n->right);
    if(!n->left && !n->right) return;
    char* lval = n->left->value ? n->left->value : n->left->addr;
    char* rval = n->right ? (n->right->value ? n->right->value : n->right->addr) : "";
    char* lop = n->lop ? n->lop : "";
    char* rop = n->rop ? n->rop : "";
    if(strcmp(n->lop, ":=") == 0 && n->left && n->right) fprintf(output_file, "%s := %s\n", lval, rval);
    else fprintf(output_file, "%s := %s%s%s%s\n", n->addr, lval, lop, rval, rop );
}

char * value(tree_node n){
    if(n->left && n->left->type == LEAF && strcmp(":=", n->lop) == 0) return value(n->left);
    return n->value ? n->value : n->addr;
}



void ensure_label(tree_node n){
    if(!n->label) n->label = label();
}




