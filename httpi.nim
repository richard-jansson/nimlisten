{.compile: "http.c".}
{.passC: "-DVERBOSE".}

type HTTP_CON_CBACK* = proc (sock: cint,get: cstring) {.cdecl.}

proc http_setup*(port: cint; cback: HTTP_CON_CBACK): cint {.cdecl,importc:"http_setup",gcsafe.}
proc http_send*(sock: cint,msg: ptr cchar,len: cint): cint {.cdecl,importc:"http_send".}
