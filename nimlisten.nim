import ui,merc  

proc onkey(key: cstring; code: cint; down: cint,propagate: ptr cint) {.cdecl.} = 
    echo "Got key: " & $key & " keycode: " & $code
#    audience_broadcast()  

audience_setup(9000) 

ui_setup(onkey);
ui_loop()
