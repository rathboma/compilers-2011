#import "code_tree.h"

int winC = 0;
int loseC = 0;
win(char* str){
    winC++;
    printf("PASS: %s\n", str);
}
lose(char* str){
    loseC++;
    printf("FAIL: %s\n", str);
}


void treeprint(){
    tree_node n = new_node();
    n->addr = gen_address();
    n->left = new_node();
    n->left->addr = gen_address();
    n->left->type = LEAF;
    printf("should print form: x = y\n");
    output(n);
    setops(n, "+", "");
    n->right = new_leaf();
    n->right->addr = gen_address();
    printf("should pring x = y + z\n");
    output(n);
    tree_node rt = new_node();
    rt->addr = gen_address();
    rt->right = n->right;
    n->right = rt;
    setops(rt, "-", "");
    rt->left = new_leaf();
    rt->left->addr = gen_address();
    printf("should print two lines: a = x - y; b = z + a\n");
    output(n);
}


main( argc, argv )
int argc;
char **argv;
    {
        
        installType("integer");
        type_entry t = resolveType(currentSymbolTable, "integer");
        t ? win("found integer") : lose("couldn't find integer");
        
        char *ad = gen_address();
        strcmp(ad, "a0") == 0 ? win("gen address canary") : lose("address not a0");
        ad = gen_address();
        strcmp(ad, "a1") == 0 ? win("gen address incremented") : lose("address not a1");
        
        int i;
        for(i = 2; i < 11; i++){
            ad = gen_address();
        }
        strcmp(ad, "b0") == 0 ? win("incremented address to b0") : lose("bad address spec");
        
        symbol_entry s = installSymbol(currentSymbolTable, "test_symbol", t, BASICSYM);
        strcmp(addr(s), "b1") == 0 ? win("resolved symbol address") : lose("didn't resolve symbol address");
        strcmp(addr(s), "b1") == 0 ? win("resolved symbol address twice") : lose("didn't resolve symbol address twice");
        
        printf("PAY ATTENTION, running operations on a tree, pay attention\n");
        treeprint();
}