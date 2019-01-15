{.compile: "/home/richard/proj/nimlisten/net.c".}
{.compile: "/home/richard/proj/nimlisten/ws.c".}
{.passC: "-I/home/richard/proj/nimlisten -mwindows -DVERBOSE".}
{.passL: "-lws2_32 -lcrypt32".}

proc audience_setup*(port: cint) {.cdecl, importc:"audience_setup".}
proc audience_bcast*(msg: cstring) {.cdecl, importc:"audience_bcast".}
## void actors_setup(int port,void (*onmsg)(char *msg,int m_len,char **resp,int r_len));
