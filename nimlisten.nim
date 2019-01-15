import ui,merc,json 

# Do we need a thread safe option for this one?
proc onmsg(msg: cstring) {.cdecl,gcsafe.} = 
    echo "NIM: Got message"
    echo $msg

actors_setup(10000,onmsg)

proc onkey(key: cstring; code: cint; down: cint,propagate: ptr cint) {.cdecl.} = 
    echo "Got key: " & $key & " keycode: " & $code
    
    var dir = if down == 1:"keydown" 
        else : "keyup"

    let resp = %* {"type": dir, "code": $code, "key": $key}

    audience_bcast($resp) 


echo "start audience"
audience_setup(9000) 

echo "start ui"
ui_setup(onkey);
ui_loop()
