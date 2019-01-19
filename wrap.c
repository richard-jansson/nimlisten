/* 
 * Wrapper function to stear clear from preprocessor trickery
 */ 

#include <unistd.h>
/* 
 * gcc -L./jpeg-9c/.libs min.c test.c -o ctest -ljpeg
 */
#include "min.h"

void jpeg_create_compress(j_compress_ptr cinfo){
    cinfo->in_color_space=JCS_RGB;
    jpeg_CreateCompress(cinfo,
        JPEG_LIB_VERSION,
        sizeof(struct jpeg_compress_struct));
}
