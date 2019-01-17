#include<winsock2.h>
#include<windows.h>
#include<ws2tcpip.h>
#include<stdio.h>
#include<string.h>
#include<ctype.h>

#include "ws.h"

#pragma comment (lib, "Ws2_32.lib")

#define VERBOSE 1

// data sent to listen thread as argument
typedef struct __http_listen_data_t {
    int port;
    void (*cback)(char *get);
} http_listen_data_t;

typedef struct __http_con_data_t {
    void (*cback)(char *get);
    char *get;
    SOCKET *con;
} http_con_data_t;

typedef struct __ll_hthread_t {
    http_con_data_t *con; 
    HANDLE *thread;
    struct __ll_hthreead_t *next;
} llhthread_t;

llhthread_t *connections,*curr_con;
HANDLE *con_lock;

HANDLE *listent;

void http_free_get(char *get){
//    free(get);
}

void send_stream_header(){
//   char **headers[]={"Content-Type:  

}

char *http_parse_get(char *imsg,int len){
    char *getp=NULL,*get;
    char *p,*k,*v;
    int getlen=0;

    // check if http 
    if(len<4) return NULL;
	if(strncmp("GET",imsg,3)) return NULL;

// extract get parameter
    p=imsg+4;
    getp=p;
    
    for(int i=0;i<12;i++){
        printf("%i: %02i '%c'\n",i,imsg[i],imsg[i]);
    }

    for(;isprint(*p)&&!isspace(*p)&&p<(imsg+len);p++);
    getlen=p-getp;
    
    printf("[getlen]=%i\n",getlen);
    get=malloc(getlen+1);
    memcpy(get,getp,getlen);
    get[getlen]=0;

    printf("[get]=%s\n",get);
        
    // flip through header fields, ignored for now
/*	for(;p<(imsg+len)||*p==0;p++){
		k=p; for(;*p!=':'&&*p!='\0';p++);  
		if(*k=='\r') break;
		if(p>=(imsg+len)) break;
		*p=0; p+=2;
		v=p; 
		if(*v=='\r') break;
		for(;*p!='\r';p++); *p=0; p++;
		if(p>=(imsg+len)) break;
#ifdef VERBOSE
		printf("{%s} => {%s}\n",k,v);
#endif
	} 
    */
    
    return get;
}

// FIXME error handling in this one!!
// fixme duplicate
SOCKET __listen2(int port){
	int ret;
	struct addrinfo *res,hints;
	SOCKET sock,cli;
	WSADATA wsad;
    char ports[10];
    sprintf(ports,"%i",port);

	ret=WSAStartup(MAKEWORD(2,2),&wsad);

	ZeroMemory(&hints,sizeof(hints));
	hints.ai_family=AF_INET;
	hints.ai_socktype=SOCK_STREAM;
	hints.ai_protocol=IPPROTO_IP;
	hints.ai_flags=AI_PASSIVE;
	
	ret=getaddrinfo(NULL,ports,&hints,&res);
	if(ret!=0){
		printf("error\n");
		return -2;
	}

	sock=socket(res->ai_family,res->ai_socktype,res->ai_protocol);
	if(sock==INVALID_SOCKET){
		printf("error creating socket\n");
		printf("%i:\n",WSAGetLastError());
		return -3;
	}

	ret=bind(sock,res->ai_addr,(int)res->ai_addrlen);
	if(ret==SOCKET_ERROR){
		printf("error binding to socket\n");
		printf("%i\t%i:\n",WSAGetLastError(),WSAGetLastError()-WSABASEERR);
		return -4;
	}

	ret=listen(sock,10);
	if(ret==SOCKET_ERROR){
		printf("error listening to socket\n");
		printf("%i\t%i:\n",WSAGetLastError(),WSAGetLastError()-WSABASEERR);
		return -5;
	}

    return sock;
}

DWORD WINAPI __http_con_thread(LPVOID p){
  http_con_data_t *con=(http_con_data_t*)p;
  SOCKET *cli=con->con;
  void (*cback)(char *)=con->cback;
  char *get=con->get;
    
    printf("GET: %s\n",get);
    cback(get);
    http_free_get(get);
    closesocket(cli);
}

DWORD WINAPI __http_listen(LPVOID p){
	con_lock=CreateMutex(NULL,FALSE,NULL);
	if(con_lock==NULL){
		printf("create mutex error\n");
		return 1;
	}
    HANDLE *cont;
    http_con_data_t *ccfg=malloc(sizeof(http_con_data_t));

    http_listen_data_t *cfg=(http_listen_data_t*)p;
    int port=cfg->port;
    void (*cback)(char *)=cfg->cback;
    char *get;

    printf("attached to port %i\n",port);

    SOCKET sock,cli;

    sock=__listen2(port);

    if(sock<0){
        printf("error: %i see net.c/__listen\n",(int)sock);
        return;
    }
	
	// is 4096 enough?
	char buf[4096];
	int r_len;
	resp_t *resp;

	for(;;){
		cli=accept(sock,NULL,NULL);
#ifdef VERBOSE
        printf("Audience: got connection\n");
#endif

		if(cli==INVALID_SOCKET){
			printf("error accepting connection\n");
			printf("%i\t%i:\n",WSAGetLastError(),WSAGetLastError()-WSABASEERR);
			continue;
		}
		
		r_len=recv(cli,buf,4096,0);

        printf("recvd=%i\n",r_len);

        /*
		get=http_parse_get(buf,r_len);
        if(!get){
            closesocket(cli);
#ifdef VERBOSE
            printf("Couldn't parse get request\n");
            continue;
#endif
        }
        */

		WaitForSingleObject(con_lock,INFINITE);
		if(connections==NULL){
			connections=malloc(sizeof(llhthread_t));
            curr_con=connections;
		}else{
			connections->next=malloc(sizeof(llhthread_t));
			curr_con=connections->next;
		}

		curr_con->next=NULL;
        curr_con->con=malloc(sizeof(http_con_data_t));

        curr_con->con->get=http_parse_get(buf,r_len);
        curr_con->con->con=cli;
        curr_con->con->cback=cback;

        if(!curr_con->con->get){
            printf("Couldn't get get\n");
        }

		curr_con->thread=CreateThread(NULL,0,__http_con_thread,curr_con->con,0,NULL);

        if(!curr_con->thread){
            printf("Failed to create thread");
        }
		ReleaseMutex(con_lock);
	}

	return 0;
}

void test_cback(char *s){
    printf("C callback: %s\n",s);
}

int http_setup(int port,void(*cback)(char *get)){
//?    cback("test.."); 
//    return 123;
//    http_listen_data_t cfg={port,cback};
    http_listen_data_t *cfg=malloc(sizeof(http_listen_data_t));

    cfg->port=port;
    cfg->cback=cback;
//    cfg->cback=test_cback;

    printf("http listening to %i\n",cfg->port);

    listent=CreateThread(NULL,0,__http_listen,(LPVOID)cfg,0,NULL);
    if(listent==NULL){
        printf("failed to create http listen thread\n");
        return 1;
    }
    return 0;
}
