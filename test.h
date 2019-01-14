void init(int port);
void recv(void (*cback)(char *str));
void onkey(char *key,int down,int client);
void close();
