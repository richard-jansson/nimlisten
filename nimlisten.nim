import ui,merc,json,system
import stream

var sport: int 


type cmdt = object
    cmd: string
    code: int 

# Do we need a thread safe option for this one?
proc onmsg(msg: cstring) {.cdecl,gcsafe.} = 
    echo "NIM: Got message"
    echo $msg
    try:     
        let jo = parseJson($msg)
        let cmd = to(jo,cmdt)
        echo "cmd: " & cmd.cmd
        echo "code: " & $cmd.code

        if cmd.cmd == "keycode":
            ui_sendkeycode(cast[cint](cmd.code))
        elif cmd.cmd == "kcdwn": 
            ui_sendkeycodedown(cast[cint](cmd.code))
        elif cmd.cmd == "kcdup": 
            ui_sendkeycodeup(cast[cint](cmd.code))
    except: 
        echo "exception"

proc onacon() {.cdecl,gcsafe.} =
    echo "Got new ws actor connection"
    system.setupForeignThreadGc()


#JsonParsingError]
    
actors_setup(10000,onacon, onmsg)

proc onkey(key: cstring; code: cint; down: cint,propagate: ptr cint) {.cdecl.} = 
    echo "Got key: " & $key & " keycode: " & $code
    
    var dir = if down == 1:"keydown" 
        else : "keyup"

    let resp = %* {"type": dir, "code": $code, "key": $key}

    audience_bcast($resp) 

echo "start ui"
ui_setup(onkey);

stream_setup(11000)

#echo "start audience"
#audience_setup(9000) 

ui_loop()
