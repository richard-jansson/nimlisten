{.compile: "/home/richard/proj/nimlisten/win.c".}
{.passC: "-I/home/richard/proj/nimlisten ".}

type CBACK* = proc (key: cstring; code: cint; down: cint) {.cdecl.}

proc ui_setup*(cback: CBACK) {.cdecl, importc: "ui_setup".}
proc ui_loop*() {.cdecl, importc: "ui_loop".}
