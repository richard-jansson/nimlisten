# 
# Grab images and send over http as motion jpeg
#

import httpi,ui,img,os

# Called on every new http connection 
proc oncon(get: cstring) {.cdecl,gcsafe.} =
    echo "got http connection: {GET}=" & $get

    var img= newSeq[cuchar](1024*768*3)

    while true:
        os.sleep(1000)
        var w,h:cint

        ui_grabscreen(cast[ptr cuchar](img),w.addr,h.addr)
        compress(img,1024,768)

proc stream_setup*(port: int) = 
    echo "starting stream"
        
    var ret = http_setup(cast[cint](port),oncon)
    echo "http reports: " & $ret


