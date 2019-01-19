# 
# Grab images and send over http as motion jpeg
#

import httpi,ui,img,os,system

const 
    FPS = 10 

# Called on every new http connection 
proc oncon(get: cstring) {.cdecl,gcsafe.} =
    system.setupForeignThreadGc()
    echo "got http connection: {GET}=" & $get

    var ret: cint
    var reti: int

    while true:
        echo "sleep..."
        os.sleep(cast[int](1000/FPS))
        var w,h:cint

        ui_getdim(w.addr,h.addr)
        
        echo "dim: " & $w & "x" & $h
        var img=newSeq[cuchar](cast[int](w)*cast[int](h)*3)
        echo "allocated"

        ret=ui_grabscreen(cast[ptr cuchar](img))

        reti = cast[int](ret);
        
        if(reti != 0) : 
            echo "ui_grabscreen failed with: " & $reti
            continue

        try: 
            compress(img,w,h)
        except IndexError:
            echo "Trouble compressing"

        echo "compress done"
    
# remember to tearDown when client exits
    system.tearDownForeignThreadGc()

proc stream_setup*(port: int) = 
    echo "starting stream"
        
    var ret = http_setup(cast[cint](port),oncon)
    echo "http reports: " & $ret


