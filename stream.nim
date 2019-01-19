# 
# Grab images and send over http as motion jpeg
#

import httpi,ui,img

# Called on every new http connection 
proc oncon(get: cstring) {.cdecl,gcsafe.} =
    echo "got http connection: {GET}=" & $get


proc stream_setup*(port: int) = 
    echo "starting stream"
        
    var ret = http_setup(cast[cint](port),oncon)
    echo "http reports: " & $ret

    var img= newSeq[cuchar](1024*768*3)
    var w,h:cint

    echo "grabbing screen"

    ui_grabscreen(cast[ptr cuchar](img),w.addr,h.addr)

    compress(img,1024,768)

# test 
#    var output=open("nimout.ppm",fmWrite)
#    var written=output.writeBuffer(cast[ptr cuchar](img),1024*768*3)
#    echo "wrote " & $written & " bytes"
#end test
