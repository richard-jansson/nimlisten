import ui,merc,json 

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
