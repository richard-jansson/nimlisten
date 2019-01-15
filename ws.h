typedef struct __resp_t {
	int len;
	char *resp;
} resp_t;

resp_t *parse_request(char *, int);
// 0 on success -1 on failure 
int ws_send(SOCKET sock,char *msg,int l);
void free_resp(resp_t *);
