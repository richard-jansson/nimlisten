{.compile: "/home/richard/proj/nimlisten/test.c".}
{.passC: "-I/home/richard/proj/nimlisten ".}

proc init*(port: cint) {.cdecl, importc: "init".}
