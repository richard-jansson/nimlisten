# remember to remove system
import min, system

const 
    Q = 90

var ppmn = 1

proc compress*(pixbuf: seq[cuchar], w: int,h: int): (ptr cuchar,int) = 
    var cinfo: jpeg_compress_struct
    var jerr: jpeg_error_mgr

    # when is mem freed?
    var mem: ptr cuchar
    var mem_size: culong
    var d: JDIMENSION

    cinfo.err=jpeg_std_error(jerr.addr)

#    cinfo.in_color_space = cast[J_COLOR_SPACE](2);

    jpeg_create_compress(cinfo.addr)

    jpeg_mem_dest(cinfo.addr,mem.addr,mem_size.addr)

    cinfo.image_width = cast[uint32](w);
    cinfo.image_height = cast[uint32](h);
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
#    cinfo.in_color_space = JCS_RGB;
#    cinfo.in_color_space = cast[J_COLOR_SPACE](2);

    echo "set_def"
    jpeg_set_defaults(cinfo.addr);
    echo "set_Q"
    jpeg_set_quality(cinfo.addr,Q,TRUE)
    echo "set_COL"
    jpeg_set_colorspace(cinfo.addr,JCS_RGB);

    echo "start_compress"
    jpeg_start_compress(cinfo.addr,TRUE)
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;

    echo "write scanlines"
    echo "W: " & $w & " H: " & $h

    echo "alloc_row" & $w
    var row=newSeq[cuchar](w*3)
    echo "alloc rows" 
    var rows=newSeq[ptr cuchar](1)
    rows[0]=cast[ptr cuchar](addr row[0])

    while cinfo.next_scanline < cinfo.image_height:
        var y = cinfo.image_height - cinfo.next_scanline - 1
        for x in countup(0,w-1):
            var o0= x*3
            var o1 = (w*cast[int](y) + x)*3
            row[o0+0]=cast[cuchar](0)
            row[o0+1]=cast[cuchar](0)
            row[o0+2]=cast[cuchar](0)

            row[o0+0]=pixbuf[o1+0]
            row[o0+1]=pixbuf[o1+2]
            row[o0+2]=pixbuf[o1+1]

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

#    var output=open("ppm/" & $ppmn & ".jpg",fmWrite)
#    ppmn = ppmn + 1
#    var written=output.writeBuffer(mem,mem_size)
#    echo "wrote " & $written & " bytes"
    
    return (mem,cast[int](mem_size))
#    return cast[int](mem_size)
