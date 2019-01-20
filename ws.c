/*
 * Naive simple websoket implementation
 *  
 * http://tools.ietf.org/html/rfc6455
 */ 
#include<winsock2.h>
#include<windows.h>
#include<ws2tcpip.h>
#include<string.h>
#include<assert.h>
#include<stdlib.h>
#include<stdio.h>
#include<stdint.h>
#include<unistd.h>
#include<errno.h>

#include<wincrypt.h>
/*#include"debug.h" */

#include"ws.h"

#define WS_KEY "Sec-WebSocket-Key"
#define WS_ACC "Sec-WebSocket-Accept"
#define KEY_SALT "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

// base 64 encoding table
char table[]=
	{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '+', '/'};

// SHA1 using Windows API 
// expects hashv to be 20 bytes
void SHA1(char *data,char *hashv){
	HCRYPTPROV provider;
	HCRYPTHASH hash;
	int len;
	DWORD dlen;

	int ret;
	ret=CryptAcquireContext(&provider,NULL,NULL,PROV_RSA_FULL,0);
	if(!ret){
		if(GetLastError()==NTE_BAD_KEYSET){
			CryptAcquireContext(&provider,NULL,NULL,PROV_RSA_FULL,CRYPT_NEWKEYSET);
		}
		else{
			printf("error acquiring context %x\n",GetLastError());
			return;
		}
	}

	ret=CryptCreateHash(provider,CALG_SHA1,0,0,&hash);
	if(!ret) printf("error creating hash");

	ret=CryptHashData(hash,(BYTE*)data,strlen(data),0);
	if(!ret) printf("error hashing");

	dlen=sizeof(DWORD);
	ret=CryptGetHashParam(hash,HP_HASHSIZE,(BYTE*)&len,&dlen,0);
	if(!ret){
		printf("error getting parameter:%x\n",GetLastError());
	}

	dlen=20;
	ret=CryptGetHashParam(hash,HP_HASHVAL,(BYTE*)hashv,&dlen,0);
	if(!ret){
		printf("Failed to get hash\n");
	}

//	printf("hash length=%i %ss\n",len,hashv);
}

// Naive base64 encoding method
//
// Expects string to be null terminated 
// returns NULL on failure
// use free to free result!
char *b64_enc(char *in,int l){
	int ol=ceil(l*8/(double)6.0);	
	char *output=(void*)malloc(ol+2);
	if(!output) return NULL;
	
	uint8_t lft,rgt,res;
	
	char *inp=in;
	char *outp=output;
	char o;

	int padding=0;

	for(int i=0;i<ol;i++){
		switch(i%4){
			case 0:
				padding=0;
				res=(*inp&0xFC)>>2;
				*(outp++)=table[res];
				break;
			case 1:
				lft=(*inp&0x3)<<4;
				inp++;
				if(inp-in==l) padding=2;
				rgt=(*inp&0xF0)>>4;
				res=lft|rgt;
				*(outp++)=table[res];
				break;
			case 2:
				lft=(*inp&0xF)<<2;
				inp++;
				if(inp-in==l) padding=1;
				rgt=(*inp&0xC0)>>6;
				res=lft|rgt;
				*(outp++)=table[res];
				break;
			case 3:
				lft=(*inp&0x3F);
				inp++;
				if(inp-in==l) padding=0;
				res=lft;
				*(outp++)=table[res];
				break;
		}
	}
	for(int i=0;i<padding;i++){
		*outp='=';
		outp++;
	}
	*outp='\0';

	return output;
}

// FIXME remember to free!
char *keyresp=NULL;

char ret[29];
char hs[41];
char *b64;

void __parse_http_header(char *k,char *v){
	unsigned char h[20];
	char *p;
	int len;
	char tmp[3];
	*tmp=0;
	tmp[2]='\0';

	if(!strncmp(WS_KEY,k,strlen(WS_KEY))){
		len=strlen(v)+strlen(KEY_SALT);

		if(keyresp==NULL) keyresp=malloc(len+1);
		assert(keyresp);

		*keyresp='\0';
		strcat(keyresp,v);
		strcat(keyresp,KEY_SALT);

		SHA1(keyresp,h);
#ifdef WS_VERBOSE
		printf("sha1(%s)\n",keyresp);
#endif
		*hs=0;
		for(int i=0;i<20;i++){
			*tmp=0;
			sprintf(tmp,"%x%x", (h[i]>>4)&0xf, h[i]&0xf);
			strcat(hs,tmp);
		}
#ifdef WS_VERBOSE
		printf("sha1=%s\n",hs);
#endif
		b64=b64_enc(h,20);
#ifdef WS_VERBOSE
		printf("b64=%s\n",b64);
#endif
		keyresp=b64;
	}else{
	}
}

// FIXME not always like this
// make sure length of response is calculated correctly
resp_t *parse_request(char *imsg, int len){

	resp_t *ret;
	ret=malloc(sizeof(resp_t));
	assert(ret);
    // FIXME test connect with nc -z and with this if block temporarily removed to iron out crash
    if(len<4){
#ifdef WS_VERBOSE
        printf("empty message skipping\n");
#endif
        ret->len=0;
        ret->resp=NULL;
        return;
    }
	char *k,*v;
	char *p=imsg;
	if(!strncmp("HTTP",imsg,4)){
		ret->resp=NULL;
		ret->len=0;
		return ret;
	}
	for(;*p!='\n'&&p<(imsg+len);p++); p++;
	
	for(;p<(imsg+len)||*p==0;p++){
		k=p; for(;*p!=':'&&*p!='\0';p++);  
		if(*k=='\r') break;
		if(p>=(imsg+len)) break;
		*p=0; p+=2;
		v=p; 
		if(*v=='\r') break;
		for(;*p!='\r';p++); *p=0; p++;
		if(p>=(imsg+len)) break;
#ifdef WS_VERBOSE
		printf("{%s} => {%s}\n",k,v);
#endif
//		p++;

		__parse_http_header(k,v);
	} 
	char *resp[]={"HTTP/1.1 101 Switching Protocols",
			"Upgrade: websocket",
			"Connection: Upgrade",
			"Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=",
//			"Sec-WebSocket-Protocol: chat",
			""};
	char *msg;
	int l=0,nrows=sizeof(resp)/sizeof(char *);
	// Are we sure about having +4*nrows padding?
	int tl;
	for(int i=0;i<nrows;i++){
		if(!strncmp(WS_ACC,resp[i],strlen(WS_ACC))){
//			tl=strlen(WS_ACC)+27+5;
			tl=20+3+28+2;
		
		}else{
			tl=strlen(resp[i])+3;
		}
		l+=tl;
	}
	msg=malloc(l);
	assert(msg);
	*msg=0;
	char *endl="\r\n";
	char *pad=": ";
#ifdef VERBOSE
	printf("length of response =%i\n",l);
	printf("ACCEPT = %s\n",hs);
#endif
	for(int i=0;i<nrows;i++){
		if(!strncmp(WS_ACC,resp[i],strlen(WS_ACC))){
#ifdef VERBOSE
			printf("WS_KEY as %s\n", hs);
#endif
			strcat(msg,WS_ACC);
			strcat(msg,pad);
			strcat(msg,b64);
		}else{
			strcat(msg,resp[i]);
		}
		strcat(msg,endl);
	}
	ret->resp=msg;
	ret->len=l-5;


	return ret;
}

void free_resp(resp_t *r){
	if(r->resp) free(r->resp);
	r->len=0;
}

/*
 *    0                   1                   2                   3
 *    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 *   +-+-+-+-+-------+-+-------------+-------------------------------+
 *   |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
 *   |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
 *   |N|V|V|V|       |S|             |   (if payload len==126/127)   |
 *   | |1|2|3|       |K|             |                               |
 *   +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
 *   |     Extended payload length continued, if payload len == 127  |
 *   + - - - - - - - - - - - - - - - +-------------------------------+
 *   |                               |Masking-key, if MASK set to 1  |
 *   +-------------------------------+-------------------------------+
 *   | Masking-key (continued)       |          Payload Data         |
 *   +-------------------------------- - - - - - - - - - - - - - - - +
 *   :                     Payload Data continued ...                :
 *   + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
 *   |                     Payload Data continued ...                |
 *   +---------------------------------------------------------------+
*/
#define HEADSIZE 2
int ws_send(SOCKET sock,char *msg,int len){
	// FIXME support messages larger than 125 bytes
	// FIXME exessive copying and allocating...
	assert(len<125);
	char *buf;
	// nibblets 
	uint8_t na,nb,nc,nd;
	buf=malloc(len+HEADSIZE);	
	assert(buf!=NULL);
	// Finnish = 1 
	buf[0]=(0b1000)<<4 | (0b0001);
	// Type = text
	buf[1]=len&0b01111111;
/*	buf[1]=(0b0001);
	buf[2]=0;
	*/
	// mask is always 0
//	buf[3]=len&0b01111111;

	memcpy((buf+HEADSIZE),msg,len);	

	// we could argue for not writing to the socket here but rather in the net layer
	int ret=send(sock,buf,len+HEADSIZE,0);
	if(ret==SOCKET_ERROR){
		printf("error!\n");
//		printf("error on socket %i\n",i-1);
	}
/*
	int ret=write(sock,buf,len+HEADSIZE);
	if(ret==-1 && errno == EPIPE){
		return -1;
	}
	*/
	free(buf);

	return 0;
}

void ws_recv(char *msg,int len,void (*cback)(char *msg)){
	int is_fin=(msg[0]&(1<<8))?1:0;
	int pl_len=msg[1]&0b01111111;
	int pl_mskd=(msg[1]&0b10000000)?1:0;

	uint8_t mask[4];
//	uint32_t mint; 
//	mint=mask[3]<<(8*3) | mask[2]<<(8*2) | mask[1]<<8 | mask[0];
	char *demasked;

//	demasked=malloc(len-5);

#ifdef WS_VERBOSE
	for(int j=0;j<100;j++){
		printf("%03i:%02x\t",j, (uint8_t)msg[j]);
	}
	printf("\n");
	printf("fin=%i len=%i msk=%i\n",is_fin,pl_len,pl_mskd);
#endif 


//	printf("mask = %x\n",mint);
// This will always be true while receiving from client, according to RFC-6455
	if(pl_mskd){
		mask[0]=msg[2];
		mask[1]=msg[3];
		mask[2]=msg[4];
		mask[3]=msg[5];
#ifdef VERBOSE
		printf("msk: %x %x %x %x\n",	
			mask[0],
			mask[1],
			mask[2],
			mask[3]);
#endif
		for(int i=0;i<len-6;i++){
			int o=i+6;
			int j=i%4;
//			printf("%i:%x => ",i,(uint8_t)msg[o]);
			msg[o]=msg[o]^mask[j];
//			printf("%i:%x %c\n",i, (uint8_t)msg[o], (uint8_t)msg[o]);
		}
	}
	msg[6+pl_len]=0;
	printf("received msg: %s\n",msg+6);
    //TODO is this 0 terminated??
    cback(msg+6);
//	vip_get_cmd(msg+6,pl_len);
}
