import testi

proc cback(str: cstring) {.cdecl.} = 
    echo "cback"
    echo str

init(20)

recv(cback)

echo "hello"
