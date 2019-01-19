{.compile: "wrap.c".}
{.passL:"-L/home/richard/proj/nimjpeg/jpeg-9c/.libs -ljpeg".}

import strutils
const sourcePath = currentSourcePath().split({'\\', '/'})[0..^2].join("/")
const headermin = sourcePath & "/min.h"
const
  JPEG_LIB_VERSION* = 90
  JPEG_LIB_VERSION_MAJOR* = 9
  JPEG_LIB_VERSION_MINOR* = 3
  DCTSIZE* = 8
  DCTSIZE2* = 64
  NUM_QUANT_TBLS* = 4
  NUM_HUFF_TBLS* = 4
  NUM_ARITH_TBLS* = 16
  MAX_COMPS_IN_SCAN* = 4
  MAX_SAMP_FACTOR* = 4

##  Unfortunately, some bozo at Adobe saw no reason to be bound by the standard;
##  the PostScript DCT filter can emit files with many more than 10 blocks/MCU.
##  If you happen to run across such a file, you can up D_MAX_BLOCKS_IN_MCU
##  to handle it.  We even let you do this from the jconfig.h file.  However,
##  we strongly discourage changing C_MAX_BLOCKS_IN_MCU; just because Adobe
##  sometimes emits noncompliant files doesn't mean you should too.
##

const
  C_MAX_BLOCKS_IN_MCU* = 10

type
  UINT16* = cushort
  UINT8* = cuchar
  JSAMPLE* = cuchar
  JCOEF* = cshort
  JOCTET* = cuchar
  JDIMENSION* = cuint
  JSAMPROW* = ptr JSAMPLE

##  ptr to one image row of pixel samples.

type
  JSAMPARRAY* = ptr JSAMPROW

##  ptr to some rows (a 2-D sample array)

type
  JSAMPIMAGE* = ptr JSAMPARRAY

##  a 3-D sample array: top index is color

type
  JBLOCK* = array[DCTSIZE2, JCOEF]

##  one block of coefficients

type
  JBLOCKROW* = ptr JBLOCK

##  pointer to one row of coefficient blocks

type
  JBLOCKARRAY* = ptr JBLOCKROW

##  a 2-D array of coefficient blocks

type
  JBLOCKIMAGE* = ptr JBLOCKARRAY

##  a 3-D array of coefficient blocks

type
  JCOEFPTR* = ptr JCOEF

##  useful in a couple of places

type
  boolean* {.size: sizeof(cint).} = enum
    FALSE = 0, TRUE = 1
  JQUANT_TBL* {.importc: "struct JQUANT_TBL", header: headermin, bycopy.} = object
    quantval* {.importc: "quantval".}: array[DCTSIZE2, UINT16] ##  This array gives the coefficient quantizers in natural array order
                                                          ##  (not the zigzag order in which they are stored in a JPEG DQT marker).
                                                          ##  CAUTION: IJG versions prior to v6a kept this array in zigzag order.
                                                          ##
    ##  quantization step for each coefficient
    ##  This field is used only during compression.  It's initialized FALSE when
    ##  the table is created, and set TRUE when it's been output to the file.
    ##  You could suppress output of a table by setting this to TRUE.
    ##  (See jpeg_suppress_tables for an example.)
    ##
    sent_table* {.importc: "sent_table".}: boolean ##  TRUE when table has been output



##  Huffman coding tables.

type
  JHUFF_TBL* {.importc: "struct JHUFF_TBL", header: headermin, bycopy.} = object
    bits* {.importc: "bits".}: array[17, UINT8] ##  These two fields directly represent the contents of a JPEG DHT marker
    ##  bits[k] = # of symbols with codes of
    ##  length k bits; bits[0] is unused
    huffval* {.importc: "huffval".}: array[256, UINT8] ##  The symbols, in order of incr code length
                                                  ##  This field is used only during compression.  It's initialized FALSE when
                                                  ##  the table is created, and set TRUE when it's been output to the file.
                                                  ##  You could suppress output of a table by setting this to TRUE.
                                                  ##  (See jpeg_suppress_tables for an example.)
                                                  ##
    sent_table* {.importc: "sent_table".}: boolean ##  TRUE when table has been output


## typedef void noreturn_t;

type
  J_COLOR_SPACE* {.size: sizeof(cint).} = enum
    JCS_UNKNOWN,              ##  error/unspecified
    JCS_GRAYSCALE,            ##  monochrome
    JCS_RGB,                  ##  red/green/blue, standard RGB (sRGB)
    JCS_YCbCr,                ##  Y/Cb/Cr (also known as YUV), standard YCC
    JCS_CMYK,                 ##  C/M/Y/K
    JCS_YCCK,                 ##  Y/Cb/Cr/K
    JCS_BG_RGB,               ##  big gamut red/green/blue, bg-sRGB
    JCS_BG_YCC                ##  big gamut Y/Cb/Cr, bg-sYCC
  J_COLOR_TRANSFORM* {.size: sizeof(cint).} = enum
    JCT_NONE = 0, JCT_SUBTRACT_GREEN = 1



##  DCT/IDCT algorithm options.

type
  J_DCT_METHOD* {.size: sizeof(cint).} = enum
    JDCT_ISLOW,               ##  slow but accurate integer algorithm
    JDCT_IFAST,               ##  faster, less accurate integer method
    JDCT_FLOAT                ##  floating-point: accurate, fast on fast HW


const
  JMSG_LENGTH_MAX* = 200
  JMSG_STR_PARM_MAX* = 80

type
  jvirt_sarray_control* {.importc: "struct jvirt_sarray_control",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jvirt_barray_control* {.importc: "struct jvirt_barray_control",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_comp_master* {.importc: "struct jpeg_comp_master", header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_c_main_controller* {.importc: "struct jpeg_c_main_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_c_prep_controller* {.importc: "struct jpeg_c_prep_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_c_coef_controller* {.importc: "struct jpeg_c_coef_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_marker_writer* {.importc: "struct jpeg_marker_writer", header: headermin,
                       bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_color_converter* {.importc: "struct jpeg_color_converter",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_downsampler* {.importc: "struct jpeg_downsampler", header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_forward_dct* {.importc: "struct jpeg_forward_dct", header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_entropy_encoder* {.importc: "struct jpeg_entropy_encoder",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_decomp_master* {.importc: "struct jpeg_decomp_master", header: headermin,
                       bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_d_main_controller* {.importc: "struct jpeg_d_main_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_d_coef_controller* {.importc: "struct jpeg_d_coef_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_d_post_controller* {.importc: "struct jpeg_d_post_controller",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_input_controller* {.importc: "struct jpeg_input_controller",
                          header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_marker_reader* {.importc: "struct jpeg_marker_reader", header: headermin,
                       bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_entropy_decoder* {.importc: "struct jpeg_entropy_decoder",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_inverse_dct* {.importc: "struct jpeg_inverse_dct", header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_upsampler* {.importc: "struct jpeg_upsampler", header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_color_deconverter* {.importc: "struct jpeg_color_deconverter",
                           header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jpeg_color_quantizer* {.importc: "struct jpeg_color_quantizer",
                         header: headermin, bycopy.} = object
    dummy* {.importc: "dummy".}: clong

  jvirt_sarray_ptr* = ptr jvirt_sarray_control
  jvirt_barray_ptr* = ptr jvirt_barray_control
  jpeg_memory_mgr* {.importc: "struct jpeg_memory_mgr", header: headermin, bycopy.} = object
    alloc_small* {.importc: "alloc_small".}: proc (a1: j_common_ptr; a2: cint; a3: csize): pointer {.
        stdcall.}
    alloc_large* {.importc: "alloc_large".}: proc (a1: j_common_ptr; a2: cint; a3: csize): pointer {.
        stdcall.}
    alloc_sarray* {.importc: "alloc_sarray".}: proc (a1: j_common_ptr; a2: cint;
        a3: JDIMENSION; a4: JDIMENSION): JSAMPARRAY {.stdcall.}
    alloc_barray* {.importc: "alloc_barray".}: proc (a1: j_common_ptr; a2: cint;
        a3: JDIMENSION; a4: JDIMENSION): JBLOCKARRAY {.stdcall.}
    request_virt_sarray* {.importc: "request_virt_sarray".}: proc (a1: j_common_ptr;
        a2: cint; a3: boolean; a4: JDIMENSION; a5: JDIMENSION; a6: JDIMENSION): jvirt_sarray_ptr {.
        stdcall.}
    request_virt_barray* {.importc: "request_virt_barray".}: proc (a1: j_common_ptr;
        a2: cint; a3: boolean; a4: JDIMENSION; a5: JDIMENSION; a6: JDIMENSION): jvirt_barray_ptr {.
        stdcall.}
    realize_virt_arrays* {.importc: "realize_virt_arrays".}: proc (a1: j_common_ptr) {.
        stdcall.}
    access_virt_sarray* {.importc: "access_virt_sarray".}: proc (a1: j_common_ptr;
        a2: jvirt_sarray_ptr; a3: JDIMENSION; a4: JDIMENSION; a5: boolean): JSAMPARRAY {.
        stdcall.}
    access_virt_barray* {.importc: "access_virt_barray".}: proc (a1: j_common_ptr;
        a2: jvirt_barray_ptr; a3: JDIMENSION; a4: JDIMENSION; a5: boolean): JBLOCKARRAY {.
        stdcall.}
    free_pool* {.importc: "free_pool".}: proc (a1: j_common_ptr; a2: cint) {.stdcall.}
    self_destruct* {.importc: "self_destruct".}: proc (a1: j_common_ptr) {.stdcall.}
    max_memory_to_use* {.importc: "max_memory_to_use".}: clong
    max_alloc_chunk* {.importc: "max_alloc_chunk".}: clong

  jpeg_progress_mgr* {.importc: "struct jpeg_progress_mgr", header: headermin, bycopy.} = object
    progress_monitor* {.importc: "progress_monitor".}: proc (cinfo: j_common_ptr) {.
        stdcall.}             ##   JMETHOD(void, progress_monitor, (j_common_ptr cinfo));
    pass_counter* {.importc: "pass_counter".}: clong ##  work units completed in this pass
    pass_limit* {.importc: "pass_limit".}: clong ##  total number of work units in this pass
    completed_passes* {.importc: "completed_passes".}: cint ##  passes completed so far
    total_passes* {.importc: "total_passes".}: cint ##  total number of passes expected

  jpeg_common_struct* {.importc: "struct jpeg_common_struct", header: headermin,
                       bycopy.} = object
    err* {.importc: "err".}: ptr jpeg_error_mgr ##  common fields
    ##  Error handler module
    mem* {.importc: "mem".}: ptr jpeg_memory_mgr ##  Memory manager module
    progress* {.importc: "progress".}: ptr jpeg_progress_mgr ##  Progress monitor, or NULL if none
    client_data* {.importc: "client_data".}: pointer ##  Available for use by application
    is_decompressor* {.importc: "is_decompressor".}: boolean ##  So common code can tell which is which
    global_stat* {.importc: "global_stat".}: cint ##  For checking call sequence validity
                                              ##  end common fields

  j_common_ptr* = ptr jpeg_common_struct
  INNER_C_UNION_min_192* {.importc: "struct no_name", header: headermin, bycopy.} = object {.
      union.}
    i* {.importc: "i".}: array[8, cint]
    s* {.importc: "s".}: array[JMSG_STR_PARM_MAX, char]

  jpeg_error_mgr* {.importc: "struct jpeg_error_mgr", header: headermin, bycopy.} = object
    error_exit* {.importc: "error_exit".}: proc (cinfo: j_common_ptr) {.stdcall.} ##  Error exit handler: does not return to caller
    ##  Conditionally emit a trace or warning message
    emit_message* {.importc: "emit_message".}: proc (cinfo: j_common_ptr;
        msg_level: cint) {.stdcall.} ##  Routine that actually outputs a trace or error message
    output_message* {.importc: "output_message".}: proc (cinfo: j_common_ptr) {.
        stdcall.}             ##  Format a message string for the most recent JPEG error or message
    format_message* {.importc: "format_message".}: proc (cinfo: j_common_ptr;
        buffer: cstring) {.stdcall.} ##  Reset error state variables at start of a new image
    reset_error_mgr* {.importc: "reset_error_mgr".}: proc (cinfo: j_common_ptr) {.
        stdcall.} ##  The message ID code and any parameters are saved here.
                 ##  A message can have one string parameter or up to 8 int parameters.
                 ##
    msg_code* {.importc: "msg_code".}: cint
    msg_parm* {.importc: "msg_parm".}: INNER_C_UNION_min_192 ##  Standard state variables for error facility
    trace_level* {.importc: "trace_level".}: cint ##  max msg_level that will be displayed
                                              ##  For recoverable corrupt-data errors, we emit a warning message,
                                              ##  but keep going unless emit_message chooses to abort.  emit_message
                                              ##  should count warnings in num_warnings.  The surrounding application
                                              ##  can check for bad data by seeing if num_warnings is nonzero at the
                                              ##  end of processing.
                                              ##
    num_warnings* {.importc: "num_warnings".}: clong ##  number of corrupt-data warnings
                                                 ##  These fields point to the table(s) of error message strings.
                                                 ##  An application can change the table pointer to switch to a different
                                                 ##  message list (typically, to change the language in which errors are
                                                 ##  reported).  Some applications may wish to add additional error codes
                                                 ##  that will be handled by the JPEG library error mechanism; the second
                                                 ##  table pointer is used for this purpose.
                                                 ##
                                                 ##  First table includes all errors generated by JPEG library itself.
                                                 ##  Error code 0 is reserved for a "no such error string" message.
                                                 ##
    jpeg_message_table* {.importc: "jpeg_message_table".}: cstringArray ##  Library errors
    last_jpeg_message* {.importc: "last_jpeg_message".}: cint ##  Table contains strings 0..last_jpeg_message
                                                          ##  Second table can be added by application (see cjpeg/djpeg for example).
                                                          ##  It contains strings numbered first_addon_message..last_addon_message.
                                                          ##
    addon_message_table* {.importc: "addon_message_table".}: cstringArray ##  Non-library errors
    first_addon_message* {.importc: "first_addon_message".}: cint ##  code for first string in addon table
    last_addon_message* {.importc: "last_addon_message".}: cint ##  code for last string in addon table


##  Dithering options for decompression.

type
  J_DITHER_MODE* {.size: sizeof(cint).} = enum
    JDITHER_NONE,             ##  no dithering
    JDITHER_ORDERED,          ##  simple ordered dither
    JDITHER_FS                ##  Floyd-Steinberg error diffusion dither


## typedef struct jpeg_compress_struct * j_compress_ptr;
## typedef struct jpeg_decompress_struct * j_decompress_ptr;

type
  jpeg_scan_info* {.importc: "struct jpeg_scan_info", header: headermin, bycopy.} = object
    comps_in_scan* {.importc: "comps_in_scan".}: cint ##  number of components encoded in this scan
    component_index* {.importc: "component_index".}: array[MAX_COMPS_IN_SCAN, cint] ##  their SOF/comp_info[] indexes
    Ss* {.importc: "Ss".}: cint
    Se* {.importc: "Se".}: cint  ##  progressive JPEG spectral selection parms
    Ah* {.importc: "Ah".}: cint
    Al* {.importc: "Al".}: cint  ##  progressive JPEG successive approx. parms

  jpeg_component_info* {.importc: "struct jpeg_component_info", header: headermin,
                        bycopy.} = object
    component_id* {.importc: "component_id".}: cint ##  These values are fixed over the whole image.
                                                ##  For compression, they must be supplied by parameter setup;
                                                ##  for decompression, they are read from the SOF marker.
    ##  identifier for this component (0..255)
    component_index* {.importc: "component_index".}: cint ##  its index in SOF or cinfo->comp_info[]
    h_samp_factor* {.importc: "h_samp_factor".}: cint ##  horizontal sampling factor (1..4)
    v_samp_factor* {.importc: "v_samp_factor".}: cint ##  vertical sampling factor (1..4)
    quant_tbl_no* {.importc: "quant_tbl_no".}: cint ##  quantization table selector (0..3)
                                                ##  These values may vary between scans.
                                                ##  For compression, they must be supplied by parameter setup;
                                                ##  for decompression, they are read from the SOS marker.
                                                ##  The decompressor output side may not use these variables.
    dc_tbl_no* {.importc: "dc_tbl_no".}: cint ##  DC entropy table selector (0..3)
    ac_tbl_no* {.importc: "ac_tbl_no".}: cint ##  AC entropy table selector (0..3)
                                          ##  Remaining fields should be treated as private by applications.
                                          ##  These values are computed during compression or decompression startup:
                                          ##  Component's size in DCT blocks.
                                          ##  Any dummy blocks added to complete an MCU are not counted; therefore
                                          ##  these values do not depend on whether a scan is interleaved or not.
                                          ##
    width_in_blocks* {.importc: "width_in_blocks".}: JDIMENSION
    height_in_blocks* {.importc: "height_in_blocks".}: JDIMENSION ##  Size of a DCT block in samples,
                                                              ##  reflecting any scaling we choose to apply during the DCT step.
                                                              ##  Values from 1 to 16 are supported.
                                                              ##  Note that different components may receive different DCT scalings.
                                                              ##
    DCT_h_scaled_size* {.importc: "DCT_h_scaled_size".}: cint
    DCT_v_scaled_size* {.importc: "DCT_v_scaled_size".}: cint ##  The downsampled dimensions are the component's actual, unpadded number
                                                          ##  of samples at the main buffer (preprocessing/compression interface);
                                                          ##  DCT scaling is included, so
                                                          ##  downsampled_width =
                                                          ##    ceil(image_width * Hi/Hmax * DCT_h_scaled_size/block_size)
                                                          ##  and similarly for height.
                                                          ##
    downsampled_width* {.importc: "downsampled_width".}: JDIMENSION ##  actual width in samples
    downsampled_height* {.importc: "downsampled_height".}: JDIMENSION ##  actual height in samples
                                                                  ##  For decompression, in cases where some of the components will be
                                                                  ##  ignored (eg grayscale output from YCbCr image), we can skip most
                                                                  ##  computations for the unused components.
                                                                  ##  For compression, some of the components will need further quantization
                                                                  ##  scale by factor of 2 after DCT (eg BG_YCC output from normal RGB input).
                                                                  ##  The field is first set TRUE for decompression, FALSE for compression
                                                                  ##  in initial_setup, and then adapted in color conversion setup.
                                                                  ##
    component_needed* {.importc: "component_needed".}: boolean ##  These values are computed before starting a scan of the component.
                                                           ##  The decompressor output side may not use these variables.
    MCU_width* {.importc: "MCU_width".}: cint ##  number of blocks per MCU, horizontally
    MCU_height* {.importc: "MCU_height".}: cint ##  number of blocks per MCU, vertically
    MCU_blocks* {.importc: "MCU_blocks".}: cint ##  MCU_width * MCU_height
    MCU_sample_width* {.importc: "MCU_sample_width".}: cint ##  MCU width in samples: MCU_width * DCT_h_scaled_size
    last_col_width* {.importc: "last_col_width".}: cint ##  # of non-dummy blocks across in last MCU
    last_row_height* {.importc: "last_row_height".}: cint ##  # of non-dummy blocks down in last MCU
                                                      ##  Saved quantization table for component; NULL if none yet saved.
                                                      ##  See jdinput.c comments about the need for this information.
                                                      ##  This field is currently used only for decompression.
                                                      ##
    quant_table* {.importc: "quant_table".}: ptr JQUANT_TBL ##  Private per-component storage for DCT or IDCT subsystem.
    dct_table* {.importc: "dct_table".}: pointer

  jpeg_destination_mgr* {.importc: "struct jpeg_destination_mgr",
                         header: headermin, bycopy.} = object
    next_output_byte* {.importc: "next_output_byte".}: ptr JOCTET
    free_in_buffer* {.importc: "free_in_buffer".}: csize
    init_destination* {.importc: "init_destination".}: proc (a1: j_compress_ptr) {.
        stdcall.}
    empty_output_buffer* {.importc: "empty_output_buffer".}: proc (
        a1: j_compress_ptr): boolean {.stdcall.}
    term_destination* {.importc: "term_destination".}: proc (a1: j_compress_ptr) {.
        stdcall.}

  jpeg_compress_struct* {.importc: "struct jpeg_compress_struct",
                         header: headermin, bycopy.} = object
    err* {.importc: "err".}: ptr jpeg_error_mgr ##  Error handler module
    mem* {.importc: "mem".}: ptr jpeg_memory_mgr ##  Memory manager module
    progress* {.importc: "progress".}: ptr jpeg_progress_mgr ##  Progress monitor, or NULL if none
    client_data* {.importc: "client_data".}: pointer ##  Available for use by application
    is_decompressor* {.importc: "is_decompressor".}: boolean ##  So common code can tell which is which
    global_state* {.importc: "global_state".}: cint ##  For checking call sequence validity
                                                ##  Destination for compressed data
    dest* {.importc: "dest".}: ptr jpeg_destination_mgr ##  Description of source image --- these fields must be filled in by
                                                   ##  outer application before starting compression.  in_color_space must
                                                   ##  be correct before you can even call jpeg_set_defaults().
                                                   ##
    image_width* {.importc: "image_width".}: JDIMENSION ##  input image width
    image_height* {.importc: "image_height".}: JDIMENSION ##  input image height
    input_components* {.importc: "input_components".}: cint ##  # of color components in input image
    in_color_space* {.importc: "in_color_space".}: J_COLOR_SPACE ##  colorspace of input image
    input_gamma* {.importc: "input_gamma".}: cdouble ##  image gamma of input image
                                                 ##  Compression parameters --- these fields must be set before calling
                                                 ##  jpeg_start_compress().  We recommend calling jpeg_set_defaults() to
                                                 ##  initialize everything to reasonable defaults, then changing anything
                                                 ##  the application specifically wants to change.  That way you won't get
                                                 ##  burnt when new parameters are added.  Also note that there are several
                                                 ##  helper routines to simplify changing parameters.
                                                 ##
    scale_num* {.importc: "scale_num".}: cuint
    scale_denom* {.importc: "scale_denom".}: cuint ##  fraction by which to scale image
    jpeg_width* {.importc: "jpeg_width".}: JDIMENSION ##  scaled JPEG image width
    jpeg_height* {.importc: "jpeg_height".}: JDIMENSION ##  scaled JPEG image height
                                                    ##  Dimensions of actual JPEG image that will be written to file,
                                                    ##  derived from input dimensions by scaling factors above.
                                                    ##  These fields are computed by jpeg_start_compress().
                                                    ##  You can also use jpeg_calc_jpeg_dimensions() to determine these values
                                                    ##  in advance of calling jpeg_start_compress().
                                                    ##
    data_precision* {.importc: "data_precision".}: cint ##  bits of precision in image data
    num_components* {.importc: "num_components".}: cint ##  # of color components in JPEG image
    jpeg_color_space* {.importc: "jpeg_color_space".}: J_COLOR_SPACE ##  colorspace of JPEG image
    comp_info* {.importc: "comp_info".}: ptr jpeg_component_info ##  comp_info[i] describes component that appears i'th in SOF
    quant_tbl_ptrs* {.importc: "quant_tbl_ptrs".}: array[NUM_QUANT_TBLS,
        ptr JQUANT_TBL]
    q_scale_factor* {.importc: "q_scale_factor".}: array[NUM_QUANT_TBLS, cint] ##  ptrs to coefficient quantization tables, or NULL if not defined,
                                                                          ##  and corresponding scale factors (percentage, initialized 100).
                                                                          ##
    dc_huff_tbl_ptrs* {.importc: "dc_huff_tbl_ptrs".}: array[NUM_HUFF_TBLS,
        ptr JHUFF_TBL]
    ac_huff_tbl_ptrs* {.importc: "ac_huff_tbl_ptrs".}: array[NUM_HUFF_TBLS,
        ptr JHUFF_TBL]         ##  ptrs to Huffman coding tables, or NULL if not defined
    arith_dc_L* {.importc: "arith_dc_L".}: array[NUM_ARITH_TBLS, UINT8] ##  L values for DC arith-coding tables
    arith_dc_U* {.importc: "arith_dc_U".}: array[NUM_ARITH_TBLS, UINT8] ##  U values for DC arith-coding tables
    arith_ac_K* {.importc: "arith_ac_K".}: array[NUM_ARITH_TBLS, UINT8] ##  Kx values for AC arith-coding tables
    num_scans* {.importc: "num_scans".}: cint ##  # of entries in scan_info array
    scan_info* {.importc: "scan_info".}: ptr jpeg_scan_info ##  script for multi-scan file, or NULL
                                                       ##  The default value of scan_info is NULL, which causes a single-scan
                                                       ##  sequential JPEG file to be emitted.  To create a multi-scan file,
                                                       ##  set num_scans and scan_info to point to an array of scan definitions.
                                                       ##
    raw_data_in* {.importc: "raw_data_in".}: boolean ##  TRUE=caller supplies downsampled data
    arith_code* {.importc: "arith_code".}: boolean ##  TRUE=arithmetic coding, FALSE=Huffman
    optimize_coding* {.importc: "optimize_coding".}: boolean ##  TRUE=optimize entropy encoding parms
    CCIR601_sampling* {.importc: "CCIR601_sampling".}: boolean ##  TRUE=first samples are cosited
    do_fancy_downsampling* {.importc: "do_fancy_downsampling".}: boolean ##  TRUE=apply fancy downsampling
    smoothing_factor* {.importc: "smoothing_factor".}: cint ##  1..100, or 0 for no input smoothing
    dct_method* {.importc: "dct_method".}: J_DCT_METHOD ##  DCT algorithm selector
                                                    ##  The restart interval can be specified in absolute MCUs by setting
                                                    ##  restart_interval, or in MCU rows by setting restart_in_rows
                                                    ##  (in which case the correct restart_interval will be figured
                                                    ##  for each scan).
                                                    ##
    restart_interval* {.importc: "restart_interval".}: cuint ##  MCUs per restart, or 0 for no restart
    restart_in_rows* {.importc: "restart_in_rows".}: cint ##  if > 0, MCU rows per restart interval
                                                      ##  Parameters controlling emission of special markers.
    write_JFIF_header* {.importc: "write_JFIF_header".}: boolean ##  should a JFIF marker be written?
    JFIF_major_version* {.importc: "JFIF_major_version".}: UINT8 ##  What to write for the JFIF version number
    JFIF_minor_version* {.importc: "JFIF_minor_version".}: UINT8 ##  These three values are not used by the JPEG code, merely copied
                                                             ##  into the JFIF APP0 marker.  density_unit can be 0 for unknown,
                                                             ##  1 for dots/inch, or 2 for dots/cm.  Note that the pixel aspect
                                                             ##  ratio is defined by X_density/Y_density even when density_unit=0.
    density_unit* {.importc: "density_unit".}: UINT8 ##  JFIF code for pixel size units
    X_density* {.importc: "X_density".}: UINT16 ##  Horizontal pixel density
    Y_density* {.importc: "Y_density".}: UINT16 ##  Vertical pixel density
    write_Adobe_marker* {.importc: "write_Adobe_marker".}: boolean ##  should an Adobe marker be written?
    color_transform* {.importc: "color_transform".}: J_COLOR_TRANSFORM ##  Color transform identifier, writes LSE marker if nonzero
                                                                   ##  State variable: index of next scanline to be written to
                                                                   ##  jpeg_write_scanlines().  Application may use this to control its
                                                                   ##  processing loop, e.g., "while (next_scanline < image_height)".
                                                                   ##
    next_scanline* {.importc: "next_scanline".}: JDIMENSION ##  0 .. image_height-1
                                                        ##  Remaining fields are known throughout compressor, but generally
                                                        ##  should not be touched by a surrounding application.
                                                        ##
                                                        ##
                                                        ##  These fields are computed during compression startup
                                                        ##
    progressive_mode* {.importc: "progressive_mode".}: boolean ##  TRUE if scan script uses progressive mode
    max_h_samp_factor* {.importc: "max_h_samp_factor".}: cint ##  largest h_samp_factor
    max_v_samp_factor* {.importc: "max_v_samp_factor".}: cint ##  largest v_samp_factor
    min_DCT_h_scaled_size* {.importc: "min_DCT_h_scaled_size".}: cint ##  smallest DCT_h_scaled_size of any component
    min_DCT_v_scaled_size* {.importc: "min_DCT_v_scaled_size".}: cint ##  smallest DCT_v_scaled_size of any component
    total_iMCU_rows* {.importc: "total_iMCU_rows".}: JDIMENSION ##  # of iMCU rows to be input to coef ctlr
                                                            ##  The coefficient controller receives data in units of MCU rows as defined
                                                            ##  for fully interleaved scans (whether the JPEG file is interleaved or not).
                                                            ##  There are v_samp_factor * DCT_v_scaled_size sample rows of each component
                                                            ##  in an "iMCU" (interleaved MCU) row.
                                                            ##
                                                            ##
                                                            ##  These fields are valid during any one scan.
                                                            ##  They describe the components and MCUs actually appearing in the scan.
                                                            ##
    comps_in_scan* {.importc: "comps_in_scan".}: cint ##  # of JPEG components in this scan
    cur_comp_info* {.importc: "cur_comp_info".}: array[MAX_COMPS_IN_SCAN,
        ptr jpeg_component_info] ##  *cur_comp_info[i] describes component that appears i'th in SOS
    MCUs_per_row* {.importc: "MCUs_per_row".}: JDIMENSION ##  # of MCUs across the image
    MCU_rows_in_scan* {.importc: "MCU_rows_in_scan".}: JDIMENSION ##  # of MCU rows in the image
    blocks_in_MCU* {.importc: "blocks_in_MCU".}: cint ##  # of DCT blocks per MCU
    MCU_membership* {.importc: "MCU_membership".}: array[C_MAX_BLOCKS_IN_MCU, cint] ##  MCU_membership[i] is index in cur_comp_info of component owning
                                                                               ##  i'th block in an MCU
    Ss* {.importc: "Ss".}: cint
    Se* {.importc: "Se".}: cint
    Ah* {.importc: "Ah".}: cint
    Al* {.importc: "Al".}: cint  ##  progressive JPEG parameters for scan
    block_size* {.importc: "block_size".}: cint ##  the basic DCT block size: 1..16
    natural_order* {.importc: "natural_order".}: ptr cint ##  natural-order position array
    lim_Se* {.importc: "lim_Se".}: cint ##  min( Se, DCTSIZE2-1 )
                                    ##
                                    ##  Links to compression subobjects (methods and private variables of modules)
                                    ##
    master* {.importc: "master".}: ptr jpeg_comp_master
    main* {.importc: "main".}: ptr jpeg_c_main_controller
    prep* {.importc: "prep".}: ptr jpeg_c_prep_controller
    coef* {.importc: "coef".}: ptr jpeg_c_coef_controller
    marker* {.importc: "marker".}: ptr jpeg_marker_writer
    cconvert* {.importc: "cconvert".}: ptr jpeg_color_converter
    downsample* {.importc: "downsample".}: ptr jpeg_downsampler
    fdct* {.importc: "fdct".}: ptr jpeg_forward_dct
    entropy* {.importc: "entropy".}: ptr jpeg_entropy_encoder
    script_space* {.importc: "script_space".}: ptr jpeg_scan_info ##  workspace for jpeg_simple_progression
    script_space_size* {.importc: "script_space_size".}: cint

  j_compress_ptr* = ptr jpeg_compress_struct

proc jpeg_CreateCompress*(cinfo: j_compress_ptr; version: cint; structsize: csize) {.
    stdcall, importc: "jpeg_CreateCompress", header: headermin.}
proc jpeg_destroy_compress*(cinfo: j_compress_ptr) {.stdcall,
    importc: "jpeg_destroy_compress", header: headermin.}
proc jpeg_finish_compress*(cinfo: j_compress_ptr) {.stdcall,
    importc: "jpeg_finish_compress", header: headermin.}
proc jpeg_write_scanlines*(cinfo: j_compress_ptr; scanlines: JSAMPARRAY;
                          num_lines: JDIMENSION): JDIMENSION {.cdecl,
    importc: "jpeg_write_scanlines".}
proc jpeg_start_compress*(cinfo: j_compress_ptr; write_all_tables: boolean) {.
    stdcall, importc: "jpeg_start_compress", header: headermin.}
proc jpeg_set_quality*(cinfo: j_compress_ptr; quality: cint; force_baseline: boolean) {.
    cdecl, importc: "jpeg_set_quality", header: headermin.}
proc jpeg_set_defaults*(cinfo: j_compress_ptr) {.cdecl, importc: "jpeg_set_defaults".}
proc jpeg_std_error*(err: ptr jpeg_error_mgr): ptr jpeg_error_mgr {.cdecl,
    importc: "jpeg_std_error", header: headermin.}
proc jpeg_mem_dest*(cinfo: j_compress_ptr; outbuffer: ptr ptr cuchar;
                   outsize: ptr culong) {.cdecl, importc: "jpeg_mem_dest".}
proc jpeg_create_compress*(cinfo: j_compress_ptr) {.cdecl, importc: "jpeg_create_compress".}


proc jpeg_set_colorspace*(cinfo: j_compress_ptr, colorspace: J_COLOR_SPACE) {.cdecl, importc:"jpeg_set_colorspace".}
