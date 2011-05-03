#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>



void reg(char* message){
    printf("REG: %s\n", message);
}

void setstr(char* a, char* b){
    a = calloc(strlen(b), sizeof(char));
    strcpy(a, b);
}