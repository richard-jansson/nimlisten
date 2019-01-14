#include<windows.h>
#include<stdio.h>
#include"ui.h"

HHOOK khook;
int running=0;

void (*ui_onkey)(char *key,int code,int down);

LRESULT CALLBACK _keyboard_hook(int n,WPARAM w,LPARAM l){
	PKBDLLHOOKSTRUCT p=(PKBDLLHOOKSTRUCT)l;
	int propagate=1;
	WCHAR key[16];
	BYTE state[256];

	GetKeyboardState(state);

	// Documentation says that key is not null temrinated??
	ToUnicode(p->vkCode,p->scanCode,state,key,16,0);

	if(n!=HC_ACTION) return propagate?CallNextHookEx(NULL,n,w,l):1;

	// Call the nim code
	if(w==WM_KEYDOWN) ui_onkey((char*)key,(int)p->vkCode,0);
	if(w==WM_KEYUP) ui_onkey((char*)key,(int)p->vkCode,1);

	return propagate?CallNextHookEx(NULL,n,w,l):1;
}

void ui_setup(void (*cback)(char *key,int code, int down,int *prop)){
	running=1;
	ui_onkey=cback;

	// grab keyboard
	khook=SetWindowsHookEx(WH_KEYBOARD_LL,_keyboard_hook,0,0);
	if(khook==NULL){
		printf("error setting hook\n");
	}
	return 0;
}

void ui_loop(){
	MSG msg;
	printf("starting win loop\n");

	while(GetMessage(&msg,NULL,0,0) > 0 && running){
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
}
