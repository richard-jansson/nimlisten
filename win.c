#include<stdio.h>
#include"ui.h"

int running=0;

void (*ui_onkey)(char *key,int code,int down);

int onkey(LPARAM l,int keyup){
	char json[64];

	PKBDLLHOOKSTRUCT p=(PKBDLLHOOKSTRUCT)l;
	WCHAR key[16];

	char buf[1024];

	
	printf("%s : %i\n",keyup?"keyup":"keydown",p->vkCode);
	sprintf(buf,"%s : %i\n",keyup?"keyup":"keydown",p->vkCode);
	
	BYTE state[256];
	GetKeyboardState(state);

	// Documentation says that key is not null temrinated??
	ToUnicode(p->vkCode,p->scanCode,state,key,16,0);

	sprintf(json,"{\"type\":\"%s\",\"code\":\"%s\"}",	keyup?"keyup":"keydown", key);

	if(-1!=findkeycode(p->vkCode) || -1!=findunicode(key)){
		net_broadcast(json);
		// block propagation
		return 0;
	}

	return 1;
}

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
	if(w==WM_KEYDOWN) ui_onkey(l,0);
	if(w==WM_KEYUP) ui_onkey(l,1);

	return propagate?CallNextHookEx(NULL,n,w,l):1;
}

void ui_setup(void (*cback)(char *key,int code, int down)){
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
	printf("starting win loop\n");
	for(;;){
	}
}
