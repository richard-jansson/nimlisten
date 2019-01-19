# remember to remove system
import min, system

const 
    Q = 90

proc compress*(pixbuf: seq[cuchar], w: int,h: int) = 
    var cinfo: jpeg_compress_struct
    var jerr: jpeg_error_mgr

    # where output is put
    var mem: ptr cuchar
    var mem_size: culong
    var d: JDIMENSION

    cinfo.err=jpeg_std_error(jerr.addr)

    jpeg_create_compress(cinfo.addr)

    jpeg_mem_dest(cinfo.addr,mem.addr,mem_size.addr)

    cinfo.image_width = cast[uint32](w);
    cinfo.image_height = cast[uint32](h);
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;

    jpeg_set_defaults(cinfo.addr);
    jpeg_set_quality(cinfo.addr,Q,TRUE)

    echo "start_compress"
    jpeg_start_compress(cinfo.addr,TRUE)

    echo "write scanlines"

    var row=newSeq[cuchar](w*3)
    var rows=newSeq[ptr cuchar](1)
    rows[0]=cast[ptr cuchar](addr row[0])

    while cinfo.next_scanline < cinfo.image_height:
        for x in countup(0,w-1):
            var o0= x*3
            var o1 = w*cast[int](cinfo.next_scanline*3) + x
            row[o0+0]=pixbuf[o1+0]
            row[o0+1]=pixbuf[o1+1]
            row[o0+2]=pixbuf[o1+2]

        d=jpeg_write_scanlines(cinfo.addr,cast[JSAMPARRAY](addr rows[0]),1)
        
#[
    d=jpeg_write_scanlines(cinfo.addr,
        cast[JSAMPARRAY](
        cast[ptr cuchar](pixbuf)
        )
        ,cast[uint32](1)) 
]#
    
    echo "finish compress"
    jpeg_finish_compress(cinfo.addr)
    echo "destroy compress"
    jpeg_destroy_compress(cinfo.addr)

    var output=open("nimout.jpg",fmWrite)
    var written=output.writeBuffer(mem,mem_size)
    echo "wrote " & $written & " bytes"
