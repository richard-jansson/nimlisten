# 
# Grab images and send over http as motion jpeg
#

import httpi

# Called on every new http connection 
proc oncon(get: cstring) {.cdecl,gcsafe.} =
    echo "got http connection: {GET}=" & $get

proc stream_setup*(port: int) = 
    echo "starting stream"
        
    var ret = http_setup(cast[cint](port),oncon)
    echo "http reports: " & $ret
