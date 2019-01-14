{.link: "/home/richard/proj/nimlisten/test.o".}
{.passC: "-I/home/richard/proj/nimlisten ".}

proc init*(port: cint) {.cdecl, importc: "init".}
