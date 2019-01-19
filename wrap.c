/* 
 * Wrapper function to stear clear from preprocessor trickery
 */ 

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

// makes assumption of RGB 3bpp
JSAMPARRAY alloc_row(int w,int h){
    printf("Allocating %i %i\n",w,h);
    unsigned char **buf; 
    buf=malloc(sizeof(unsigned char*)*h);
    for(int y=0;y<h;y++){
        buf[y]=malloc(sizeof(unsigned char *)*w*3); 
        for(int x=0;x<w*3;x+=3){
            buf[y][x+0]=x;
            buf[y][x+1]=x;
            buf[y][x+2]=x;
        }
    }
    printf("%i %i %i\n",
        buf[10][9],
        buf[10][10],
        buf[10][11]);
    return (JSAMPARRAY) buf;
}
