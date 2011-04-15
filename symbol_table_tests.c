#import "symbol_table.h"

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

main( argc, argv )
int argc;
char **argv;
    {
        
        installType("integer");
        resolveType(currentSymbolTable, "integer") ? win("found integer") : lose("couldn't find integer");
        
        
        
}