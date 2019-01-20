# 
# Grab images and send over http as motion jpeg
#

import httpi,ui,img,os,system

const 
    FPS = 10 

# Called on every new http connection 
proc oncon(sock: cint, get: cstring) {.cdecl,gcsafe.} =
    system.setupForeignThreadGc()
    echo "got http connection: {GET}=" & $get
    echo "on socket " & $cast[int](sock)

    var ret: cint
    var reti: int
    var jlen: int
    var http_sent: int
    var active = true

    var boundary="--MJPEGBOUNDARY"

    while active:
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
            let (compi,compilen)=compress(img,w,h)
            echo "[stream] compress done. len: " & $compilen

            # send boundary
            http_sent=http_send(sock,cast[ptr cchar](boundary.addr),cast[cint](boundary.len-1))
            if(http_sent < 0 ):
                active=false
            
            # send header for jpeg file
            var interheader=  "Content-Type: image/jpeg\r\n" & "Content-Length: " & $compilen & "\r\n" & "\r\n"
            http_sent=http_send(sock,cast[ptr cchar](interheader),cast[cint](interheader.len))
            if(http_sent < 0 ):
                active=false

            # send image
            http_sent=http_send(sock,cast[ptr cchar](compi),cast[cint](compilen))
            if(http_sent < 0 ):
                active=false

        except IndexError:
            echo "Trouble compressing" 
            continue
       
    echo "Connection closed"
# remember to tearDown when client exits
    system.tearDownForeignThreadGc()

proc stream_setup*(port: int) = 
    echo "starting stream"
        
    var ret = http_setup(cast[cint](port),oncon)
    echo "http reports: " & $ret


