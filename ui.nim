{.compile: "/home/richard/proj/nimlisten/win.c".}
{.passC: "-I/home/richard/proj/nimlisten -mwindows".}
{.passL: "-lgdi32".}

type CBACK* = proc (key: cstring; code: cint; down: cint,propagate: ptr cint) {.cdecl.}

proc ui_setup*(cback: CBACK) {.cdecl, importc: "ui_setup".}
proc ui_loop*() {.cdecl, importc: "ui_loop".}
proc ui_sendkeycode*(key: cint) {.cdecl, importc: "ui_sendkeycode".}
proc ui_sendkeycodedown*(key: cint) {.cdecl, importc: "ui_sendkeycodedown".}
proc ui_sendkeycodeup*(key: cint) {.cdecl, importc: "ui_sendkeycodeup".}
proc ui_grabscreen*(img: ptr cuchar): cint {.cdecl, importc: "ui_grabscreen".}
proc ui_getdim*(w: ptr cint,h: ptr cint) {.cdecl, importc: "ui_getdim".}

proc ui_movepointer*(x: cint,y: cint) {.cdecl, importc:"ui_movepointer".}
proc ui_buttondown*(i: cint,d: cint) {.cdecl, importc:"ui_buttondown".}
