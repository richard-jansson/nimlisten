void audience_setup(int port);
void audience_bcast(char *msg);


void actors_setup(int port,void (*onacon)(),void (*onmsg)(char *msg,int sock));
