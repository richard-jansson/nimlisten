#include<winsock2.h>
#include<windows.h>
#include<ws2tcpip.h>
#include<stdio.h>
#include<string.h>

#include "ws.h"

#pragma comment (lib, "Ws2_32.lib")

void (*onmsg)(char *msg);

HANDLE cli_lock;
HANDLE lock;
HANDLE *audience,*actor;

// Audience -> connections to which we send keypresses
typedef struct __ll_sock_t {
	SOCKET sock;	
	struct __ll_sock_t *next;
} llsock_t;

llsock_t *clients=NULL;

// actors -> connections from which we receive commands

typedef struct __ll_thread_t {
	HANDLE thread;
	struct __ll_thread_t *next;
} llthread_t;

llthread_t *actors,*curr;

// FIXME error handling in this one!!
SOCKET __listen(int port){
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

DWORD WINAPI __audience_setup(LPVOID p){
    int port= *((int*)p);
	llsock_t *curr;
    printf("attached to port %i\n",port);

	cli_lock=CreateMutex(NULL,FALSE,NULL);
	if(cli_lock==NULL){
		printf("create mutex error\n");
		return 1;
	}

    SOCKET sock,cli;

    sock=__listen(port);

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

		resp=parse_request(buf,r_len);
        printf("sending %s\n",resp);
		if(resp->resp!=NULL)  send(cli,resp->resp,resp->len,0);
		else continue;


		WaitForSingleObject(cli_lock,INFINITE);
		// FIXME lock clients 
		if(clients==NULL){
			// FIXME check malloc error
			clients=malloc(sizeof(llsock_t));
			curr=clients;
		}else{
			clients->next=malloc(sizeof(llsock_t));
			curr=clients->next;
		}
		curr->next=NULL;

		curr->sock=cli;
		printf("Attached new client!\n");
		ReleaseMutex(cli_lock);
	}

	return 0;
}


void audience_bcast(char *buf){
	llsock_t *curr=clients;	
//	char *buf="hello world\r\n";
	int i=0,ret;

	printf("net broadcast...\n");

	// FIXME check for abandoned ...
	WaitForSingleObject(cli_lock,INFINITE);

	while(curr!=NULL){
		printf("sending to socket %i...\n",i++);	
/*		ret=send(curr->sock,buf,strlen(buf+1),0);
		if(ret==SOCKET_ERROR){
			printf("error on socket %i\n",i-1);
		}
		*/

		ws_send(curr->sock,buf,strlen(buf));
		curr=curr->next;
	}

	ReleaseMutex(cli_lock);
}

// Each actor receives their own thread 
DWORD WINAPI actorthread(LPVOID p){
	SOCKET *sock=(SOCKET *)p;		
	char buf[8192];
	int r_len;

	printf("actor thread initiated...\n");

	for(;;){
		// FIXME what if buffer is bigger than 8192
		r_len=recv(*sock,buf,8192,0);
		if(r_len<1){
			printf("recv error: %i\n",GetLastError());
			return;
		}
		printf("r_len=%i\n",r_len);
		ws_recv(buf,r_len,onmsg);
	}
}

// Listen for connections on actor port 
// Parse http commands and initiate a ws con
// Spawn a thread for each client 
DWORD WINAPI __actor_setup(LPVOID p){
    SOCKET sock,cli;
    int port= *((int*)p);

    sock=__listen(port);
    if(sock<0){
        printf("error: %i see net.c/__listen\n",(int)sock);
        return;
    }
    printf("actor listening to port %i\n",port);

	// is 4096 enough?
	char buf[4096];
	int r_len;
	resp_t *resp;

	for(;;){
		cli=accept(sock,NULL,NULL);

		if(cli==INVALID_SOCKET){
			printf("error accepting connection\n");
			printf("%i\t%i:\n",WSAGetLastError(),WSAGetLastError()-WSABASEERR);
			continue;
		}
		
		r_len=recv(cli,buf,4096,0);

		resp=parse_request(buf,r_len);
		if(resp->resp!=NULL){ 
			send(cli,resp->resp,resp->len,0);
		}else {
			printf("error\n");
		}

		if(actors==NULL){
			actors=malloc(sizeof(llthread_t));
			curr=actors;
		}else{
			actors->next=malloc(sizeof(llthread_t));
			curr=actors->next;
		}
		curr->next=NULL;
		curr->thread=CreateThread(NULL,0,actorthread,&cli,0,NULL);
		// FIXME error handling

		printf("Attached new actor!\n");
	}
}

void actors_setup(int port,void (*cback)(char *msg)){
    onmsg=cback;
    actor=CreateThread(NULL,0,__actor_setup,(LPVOID)&port,0,NULL);
    if(actor==NULL){
        printf("failed to create audience thread\n");
        return 1;
    }
    printf("thread listening for new actors up and running");
    return 0;
}
int audience_setup(int port){
    audience=CreateThread(NULL,0,__audience_setup,(LPVOID)&port,0,NULL);
    if(audience==NULL){
        printf("failed to create audience thread\n");
        return 1;
    }
    return 0;
}
