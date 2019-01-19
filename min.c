#include<stdlib.h>
#include <unistd.h>

/* 
 * gcc -L./jpeg-9c/.libs min.c test.c -o ctest -ljpeg
 */
#include "min.h"

void jpeg_create_compress(j_compress_ptr cinfo){
    jpeg_CreateCompress(cinfo,
        JPEG_LIB_VERSION,
        sizeof(struct jpeg_compress_struct));
}

JSAMPARRAY *alloc_row(int w){
    unsigned char *row=malloc(w*3);
    for(int i=0;i<w;i+=3){
        row[i+0]=i;
        row[i+1]=i;
        row[i+2]=i;
    }
    return (JSAMPARRAY t)row;
}
