#include<stdio.h>
#include"ui.h"

void (*ui_onkey)(char *key,int code,int down);

void ui_setup(void (*cback)(char *key,int code, int down)){
	printf("foo\n");
	return 0;
}

void ui_loop(){
	printf("starting win loop\n");
	for(;;){
	}
}
