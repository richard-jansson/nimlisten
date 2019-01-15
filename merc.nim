{.compile: "/home/richard/proj/nimlisten/net.c".}
{.compile: "/home/richard/proj/nimlisten/ws.c".}
{.passC: "-I/home/richard/proj/nimlisten -mwindows -DVERBOSE".}
{.passL: "-lws2_32 -lcrypt32".}

type MSGCBACK* = proc (msg: cstring) {.cdecl.}

proc audience_setup*(port: cint) {.cdecl, importc:"audience_setup".}
proc audience_bcast*(msg: cstring) {.cdecl, importc:"audience_bcast".}

#proc actors_setup(port: cint;onmsg: MSGCBACK) {.cdecl, importc:"actors_setup".}
proc actors_setup*(port: cint; onmsg: MSGCBACK) {.cdecl, importc:"actors_setup".}
