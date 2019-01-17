#include<windows.h>
#include<unistd.h>
#include<stdio.h>
#include"ui.h"

#define FPS 10 

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

// not threadsafe!!
int ppm_n=0;
// ppm is nice for quickly testing images
void writeppm(unsigned char *out,int w,int h){
    // pot oveflow!!
    char path[1024];
    sprintf(path,"ppm/%i.ppm",ppm_n++);
    FILE *fd=fopen(path,"w");

    printf("writing %s\n",path);
    // assert!!

    printf("dimensions %i %i\n",w,h);
    
    int hsize=sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
    hsize=14;
    printf("header size=%i %i %i\n",hsize,
        sizeof(BITMAPFILEHEADER),
        sizeof(BITMAPINFOHEADER));


    fprintf(fd,"P6\n%i %i 255 \n",w,h);
    fwrite(out,1,w*h*3,fd);
    fclose(fd);
}

void freesgrab(unsigned char *buf){
    if(buf) free(buf);
}

// Possible optimizations
// Keep track of DCs etcetera 
// don't copy buffer 
// done this way to make safe with threads 
void ui_grabscreen(unsigned char *out,int *width,int *height){ 
    HDC screen,dst;

    printf("GetDc\n");
    screen=GetDC(NULL);
    printf("CreateCompatDC\n");
    dst=CreateCompatibleDC(screen);
    if(!dst){
        printf("Failed to create compatible DC\n");
        return;
    }
   
    printf("System metrics...\n");
    int w=GetSystemMetrics(SM_CXSCREEN);
    int h=GetSystemMetrics(SM_CYSCREEN);
    printf("%ix%i\n",w,h);

    BITMAPINFO bmi;
    HBITMAP hbmp;
    BITMAP bmp;
    void *buffer;

    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = w;
    bmi.bmiHeader.biHeight = h;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 24;
    // what options do we have here??
    bmi.bmiHeader.biCompression = BI_RGB;
    bmi.bmiHeader.biSizeImage = 0;
    bmi.bmiHeader.biXPelsPerMeter = 0;
    bmi.bmiHeader.biYPelsPerMeter = 0;
    bmi.bmiHeader.biClrUsed = 0;
    bmi.bmiHeader.biClrImportant = 0;

    printf("CreateDIB\n");
    hbmp = CreateDIBSection(dst,&bmi,DIB_RGB_COLORS,&buffer,NULL,0);
    if(!hbmp){
        printf("Failed to create DIB section\n");
    }
    
    if(!SelectObject(dst,hbmp)){
        printf("!Select Object!!\n");
    }

    printf("GetObject\n");
    GetObject(hbmp,sizeof(BITMAP),&bmp);
    // init done 

    printf("bitblt\n");
    BitBlt(dst,0,0,w,h,screen,0,0,SRCCOPY|CAPTUREBLT);

//   printf("allocating\n");
//    *buf=malloc(w*h*3);
//    char *out=*buf;
    // assert!!
    printf("copying!\n");
    memcpy(out,buffer,w*h*3);
    *width=w;
    *height=h;

    printf("cleaning up!\n");
    ReleaseDC(NULL,screen);
    DeleteDC(dst);
    DeleteObject(hbmp);
    DeleteDC(screen);
    printf("grab is done\n");
}

void ui_loop(){
	MSG msg;
	printf("starting win loop\n");

    int w,h;
    unsigned char *img=NULL;

/*
    ui_grabscreen(&img,&w,&h);
    writeppm(img,w,h);
    */
        
//    SetTimer(NULL,100,1000/FPS,NULL);

    while(running){
//        printf("timer!\n");
//        grabscreen(&img,&w,&h);
//        writeppm(img,w,h);
        
//        sleep(1);
       
        // let windows know we're alive 
        while(PeekMessage(&msg,NULL,0,0,PM_REMOVE)){
		    TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

/*	while(GetMessage(&msg,NULL,0,0) > 0 && running){
        printf("%i\n",msg);
                // only one timer so nevermind timerid
                printf("timer!\n");
                grabscreen(&img,&w,&h);
                writeppm(img,w,h);
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
    */
}
