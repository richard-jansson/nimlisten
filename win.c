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

void ui_sendkeycodedown(int key){
	UnhookWindowsHookEx(khook);
	
	keybd_event(key,0,0,0);

	khook=SetWindowsHookEx(WH_KEYBOARD_LL,_keyboard_hook,0,0);
	if(khook==NULL){
		printf("error setting hook\n");
	}
}
void ui_sendkeycodeup(int key){
	UnhookWindowsHookEx(khook);
	
	keybd_event(key,0,KEYEVENTF_KEYUP,0);

	khook=SetWindowsHookEx(WH_KEYBOARD_LL,_keyboard_hook,0,0);
	if(khook==NULL){
		printf("error setting hook\n");
	}
}
void ui_sendkeycode(int key){
	UnhookWindowsHookEx(khook);
	
	keybd_event(key,0,0,0);
	keybd_event(key,0,KEYEVENTF_KEYUP,0);

	khook=SetWindowsHookEx(WH_KEYBOARD_LL,_keyboard_hook,0,0);
	if(khook==NULL){
		printf("error setting hook\n");
	}
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
    
    HDC screen,dst;
    screen=GetDC(NULL);
    dst=CreateCompatibleDC(screen);
    if(!dst){
        printf("Failed to create compatible DC\n");
        return;
    }

    BITMAPINFO bmi;
    HBITMAP hbmp;
    BITMAP bmp;
    void *buffer;

    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = 512;
    bmi.bmiHeader.biHeight = 512;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 24;
    // what options do we have here??
    bmi.bmiHeader.biCompression = BI_RGB;
    bmi.bmiHeader.biSizeImage = 0;
    bmi.bmiHeader.biXPelsPerMeter = 0;
    bmi.bmiHeader.biYPelsPerMeter = 0;
    bmi.bmiHeader.biClrUsed = 0;
    bmi.bmiHeader.biClrImportant = 0;

    hbmp = CreateDIBSection(dst,&bmi,DIB_RGB_COLORS,&buffer,NULL,0);
    if(!hbmp){
        printf("Failed to create DIB section\n");
    }
    
    if(!SelectObject(dst,hbmp)){
        printf("!Select Object!!\n");
    }

    GetObject(hbmp,sizeof(BITMAP),&bmp);
    // init done 

    BitBlt(dst,0,0,512,512,screen,0,0,SRCCOPY|CAPTUREBLT);
    
    FILE *fd=fopen("grab.ppm","w");
    
    fprintf(fd,"P6\n%i %i 255 \n",512,512);
    fwrite(buffer,1,512*512*3,fd);
    fclose(fd);

	while(GetMessage(&msg,NULL,0,0) > 0 && running){
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
}
