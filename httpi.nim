{.compile: "http.c".}
{.passC: "-DVERBOSE".}

type HTTP_CON_CBACK* = proc (get: cstring) {.cdecl.}

proc http_setup*(port: cint; cback: HTTP_CON_CBACK): cint {.cdecl,importc:"http_setup",gcsafe.}
