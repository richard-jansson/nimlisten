#include<stdio.h>

#include"test.h"

void init(int port){
	printf("initialzing at %i\n",port);
}

void close(){
	printf("destroying server\n");
}
