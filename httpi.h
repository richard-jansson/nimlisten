int http_setup(int port,void(*cback)(int sock,char *get));
int http_send(int sock,char *msg,int len);
