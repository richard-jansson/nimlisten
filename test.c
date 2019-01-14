#include<stdio.h>

#include"test.h"

void init(int port){
	printf("initialzing at %i\n",port);
}

void recv(void (*cback)(char *str)){
    char *arg="arg";
    printf("received message\n");
    cback(arg); 
}

void close(){
	printf("destroying server\n");
}
