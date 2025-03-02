/*
  ImageMagick Image Methods.
*/
#ifndef _IMAGE_H
#define _IMAGE_H

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

#if defined(QuantumLeap)
/*
  Color quantum is [0..65535].
*/
#define DownScale(quantum)  (((unsigned int) (quantum)) >> 8)
#define HexColorFormat "#%04x%04x%04x"
#define MaxRGB  65535L
#define MaxRunlength  65535L
#define QuantumDepth  16
#define UpScale(quantum)  (((unsigned int) (quantum))*257)
#define XDownScale(color)  ((unsigned int) (color))
#define XUpScale(color)  ((unsigned int) (color))

typedef unsigned short Quantum;
#else
/*
  Color quantum is [0..255].
*/
#define DownScale(quantum)  ((unsigned int) (quantum))
#define HexColorFormat "#%02x%02x%02x"
#define MaxRGB  255
#define MaxRunlength  255
#define QuantumDepth  8
#define UpScale(quantum)  ((unsigned int) (quantum))
#define XDownScale(color)  (((unsigned int) (color)) >> 8)
#define XUpScale(color)  (((unsigned int) (color))*257)

typedef unsigned char Quantum;
#endif

/*
  Typedef declarations.
*/
typedef struct _ColorPacket
{
  Quantum
    red,
    green,
    blue;

  unsigned short
    index;

  unsigned char
    flags;

  char
    key[3];

  unsigned long
    count;
} ColorPacket;

typedef struct _ContributionInfo
{
  int
    pixel;

  double
    weight;
} ContributionInfo;

typedef struct _FilterInfo
{
  double
    (*function)(double),
    width;
} FilterInfo;

typedef struct _FrameInfo
{
  int
    x,
    y;

  unsigned int
    width,
    height;

  int
    inner_bevel,
    outer_bevel;
} FrameInfo;

typedef struct _ImageInfo
{
  FILE
    *file;

  char
    filename[MaxTextExtent],
    magick[MaxTextExtent];

  unsigned int
    affirm,
    temporary,
    subimage,
    subrange;

  char
    *server_name,
    *size,
    *tile,
    *page,
    *dispose,
    *delay,
    *iterations,
    *texture,
    *view,
    *box,
    *font,
    *pen,
    *density;

  unsigned int
    linewidth,
    pointsize,
    adjoin,
    antialias,
    depth,
    dither,
    monochrome,
    quality,
    verbose;

  int
    fuzz;

  ColorspaceType
    colorspace;

  CompressionType
    compression;

  InterlaceType
    interlace;

  ResolutionType
    units;

  FilterType
    filter;

  PreviewType
    preview_type;

  long
    group;

  char
    *background_color,
    *border_color,
    *matte_color;

  char
    unique[MaxTextExtent];

  unsigned int
    ping;
} ImageInfo;

typedef struct _MontageInfo
{
  char
    filename[MaxTextExtent];

  char
    *geometry,
    *tile,
    *background_color,
    *border_color,
    *matte_color,
    *title,
    *frame,
    *texture,
    *pen,
    *font;

  unsigned int
    pointsize,
    border_width,
    gravity,
    shadow;

  CompositeOperator
    compose;
} MontageInfo;

typedef struct _PointInfo
{
  float
    x,
    y,
    z;
} PointInfo;

typedef struct _PrimitiveInfo
{
  PrimitiveType
    primitive;

  unsigned int
    coordinates;

  float
    x,
    y;

  PaintMethod
    method;

  char
    *text;
} PrimitiveInfo;

typedef struct _RectangleInfo
{
  unsigned int
    width,
    height;

  int
    x,
    y;
} RectangleInfo;

typedef struct _RunlengthPacket
{
  Quantum
    red,
    green,
    blue,
    length;

  unsigned short
    index;
} RunlengthPacket;

typedef struct _SegmentInfo
{
  float
    x1,
    y1,
    x2,
    y2;
} SegmentInfo;

typedef struct _ProfileInfo
{
  unsigned int
    length;

  unsigned char
    *info;
} ProfileInfo;

typedef struct _ChromaticityInfo
{
  PointInfo
    red_primary,
    green_primary,
    blue_primary,
    white_point;
} ChromaticityInfo;

typedef struct _Image
{
  FILE
    *file;

  int
    exempt,
    status,
    temporary;

  char
    filename[MaxTextExtent];

  long int
    filesize;

  int
    pipe;

  char
    magick[MaxTextExtent],
    *comments,
    *label,
    *text;

  IdType
    id;

  ClassType
#if defined(__cplusplus) || defined(c_plusplus)
    c_class;
#else
    class;
#endif

  unsigned int
    matte;

  CompressionType
    compression;

  unsigned int
    columns,
    rows,
    depth;

  int
    offset;

  RectangleInfo
    tile_info;

  InterlaceType
    interlace;

  unsigned int
    scene;

  char
    *montage,
    *directory;

  ColorPacket
    *colormap;

  unsigned int
    colors;

  ColorspaceType
    colorspace;

  RenderingIntent
    rendering_intent;

  float
    gamma;

  ChromaticityInfo
    chromaticity;

  ProfileInfo
    color_profile,
    iptc_profile;

  ResolutionType
    units;

  float
    x_resolution,
    y_resolution;

  char
    *signature;

  RunlengthPacket
    *pixels,
    *packet;

  unsigned long
    packets;

  unsigned int
    packet_size;

  unsigned char
    *packed_pixels;

  ColorPacket
    background_color,
    border_color,
    matte_color;

  char
    *geometry,
    *page;

  unsigned int
    dispose,
    delay,
    iterations;

  int
    fuzz;

  FilterType
    filter;

  unsigned long
    total_colors;

  unsigned int
    mean_error_per_pixel;

  double
    normalized_mean_error,
    normalized_maximum_error;

  long int
    magick_time;

  char
    magick_filename[MaxTextExtent];

  unsigned int
    magick_columns,
    magick_rows;

  int
    tainted;

  unsigned int
    orphan;

  struct _Image
    *previous,
    *list,
    *next;
} Image;

typedef struct _AnnotateInfo
{
  ImageInfo
    *image_info;

  unsigned int
    gravity;

  char
    *geometry,
    *text,
    *primitive,
    *font_name;

  Image
    *tile;

  RectangleInfo
    bounds;
} AnnotateInfo;

/*
  Image const declarations.
*/
extern const char
  *Alphabet,
  *DefaultPointSize,
  *DefaultImageQuality,
  *DefaultTileFrame,
  *DefaultTileGeometry,
  *DefaultTileLabel,
  *PSDensityGeometry,
  *PSPageGeometry,
  *ReadBinaryType,
  *ReadBinaryUnbufferedType,
  *WriteBinaryType;

extern const double
  SharpenFactor;

/*
  Image utilities methods.
*/
extern Export AnnotateInfo
  *CloneAnnotateInfo(const ImageInfo *,const AnnotateInfo *);

extern Export Image
  *AddNoiseImage(const Image *,const NoiseType),
  *AllocateImage(const ImageInfo *),
  *AppendImages(Image *,const unsigned int),
  *AverageImages(const Image *),
  *BlurImage(const Image *,const double),
  *BorderImage(const Image *,const RectangleInfo *),
  *ChopImage(const Image *,const RectangleInfo *),
  *CloneImage(const Image *,const unsigned int,const unsigned int,
    const unsigned int),
  *CreateImage(const unsigned int,const unsigned int,const float *,
    const float *,const float *,const float *),
  *CropImage(const Image *,const RectangleInfo *),
  *DespeckleImage(Image *),
  *EdgeImage(const Image *,const double),
  *EmbossImage(const Image *),
  *EnhanceImage(const Image *),
  *FlipImage(const Image *),
  *FlopImage(const Image *),
  *FrameImage(const Image *,const FrameInfo *),
  *ImplodeImage(Image *,const double),
  **ListToGroupImage(const Image *,unsigned int *),
  *MagnifyImage(Image *),
  *MinifyImage(Image *),
  *MontageImages(const Image *,const MontageInfo *),
  *MorphImages(Image *,const unsigned int),
  *OilPaintImage(Image *,const unsigned int),
  *ReadAVSImage(const ImageInfo *image_info),
  *ReadBMPImage(const ImageInfo *image_info),
  *ReadCMYKImage(const ImageInfo *image_info),
  *ReadDCMImage(const ImageInfo *image_info),
  *ReadDPSImage(const ImageInfo *image_info),
  *ReadFAXImage(const ImageInfo *image_info),
  *ReadFITSImage(const ImageInfo *image_info),
  *ReadFPXImage(const ImageInfo *image_info),
  *ReadGIFImage(const ImageInfo *image_info),
  *ReadGRADATIONImage(const ImageInfo *image_info),
  *ReadGRAYImage(const ImageInfo *image_info),
  *ReadHDFImage(const ImageInfo *image_info),
  *ReadHISTOGRAMImage(const ImageInfo *image_info),
  *ReadICCImage(const ImageInfo *image_info),
  *ReadICONImage(const ImageInfo *image_info),
  *ReadImage(ImageInfo *),
  *ReadIPTCImage(const ImageInfo *image_info),
  *ReadJBIGImage(const ImageInfo *image_info),
  *ReadJPEGImage(const ImageInfo *image_info),
  *ReadLABELImage(const ImageInfo *image_info),
  *ReadLOGOImage(const ImageInfo *image_info),
  *ReadMAPImage(const ImageInfo *image_info),
  *ReadMIFFImage(const ImageInfo *image_info),
  *ReadMONOImage(const ImageInfo *image_info),
  *ReadMTVImage(const ImageInfo *image_info),
  *ReadNULLImage(const ImageInfo *image_info),
  *ReadPCDImage(const ImageInfo *image_info),
  *ReadPCLImage(const ImageInfo *image_info),
  *ReadPCXImage(const ImageInfo *image_info),
  *ReadPDFImage(const ImageInfo *image_info),
  *ReadPICTImage(const ImageInfo *image_info),
  *ReadPIXImage(const ImageInfo *image_info),
  *ReadPLASMAImage(const ImageInfo *image_info),
  *ReadPNGImage(const ImageInfo *image_info),
  *ReadPNMImage(const ImageInfo *image_info),
  *ReadPSDImage(const ImageInfo *image_info),
  *ReadPSImage(const ImageInfo *image_info),
  *ReadPWPImage(const ImageInfo *image_info),
  *ReadRGBImage(const ImageInfo *image_info),
  *ReadRLAImage(const ImageInfo *image_info),
  *ReadRLEImage(const ImageInfo *image_info),
  *ReadSFWImage(const ImageInfo *image_info),
  *ReadSGIImage(const ImageInfo *image_info),
  *ReadSTEGANOImage(const ImageInfo *image_info),
  *ReadSUNImage(const ImageInfo *image_info),
  *ReadTGAImage(const ImageInfo *image_info),
  *ReadTIFFImage(const ImageInfo *image_info),
  *ReadTILEImage(const ImageInfo *image_info),
  *ReadTIMImage(const ImageInfo *image_info),
  *ReadTTFImage(const ImageInfo *image_info),
  *ReadTXTImage(const ImageInfo *image_info),
  *ReadUILImage(const ImageInfo *image_info),
  *ReadUYVYImage(const ImageInfo *image_info),
  *ReadVICARImage(const ImageInfo *image_info),
  *ReadVIDImage(const ImageInfo *image_info),
  *ReadVIFFImage(const ImageInfo *image_info),
  *ReadXImage(const ImageInfo *image_info),
  *ReadXBMImage(const ImageInfo *image_info),
  *ReadXCImage(const ImageInfo *image_info),
  *ReadXPMImage(const ImageInfo *image_info),
  *ReadXWDImage(const ImageInfo *image_info),
  *ReadYUVImage(const ImageInfo *image_info),
  *ReduceNoiseImage(const Image *),
  *RollImage(const Image *,const int,const int),
  *RotateImage(const Image *,const double,const unsigned int,
    const unsigned int),
  *SampleImage(const Image *,const unsigned int,const unsigned int),
  *ScaleImage(const Image *,const unsigned int,const unsigned int),
  *ShadeImage(Image *,const unsigned int,double,double),
  *SharpenImage(const Image *,const double),
  *ShearImage(const Image *,const double,const double,const unsigned int),
  *SpreadImage(Image *,const unsigned int),
  *SteganoImage(Image *,Image *),
  *StereoImage(Image *,const Image *),
  *SwirlImage(Image *,double),
  *WaveImage(Image *,const double,const double),
  *ZoomImage(Image *,const unsigned int,const unsigned int);

extern Export ImageInfo
  *CloneImageInfo(const ImageInfo *);

extern Export ImageType
  GetImageType(Image *);

extern Export int
  ParseImageGeometry(const char *,int *,int *,unsigned int *,unsigned int *);

extern Export unsigned int
  AnimateImages(const ImageInfo *image_info,Image *image),
  DisplayImages(const ImageInfo *image_info,Image *image),
  GetNumberScenes(const Image *),
  IsGeometry(const char *),
  IsGrayImage(Image *),
  IsMonochromeImage(Image *),
  IsPseudoClass(Image *),
  IsSubimage(const char *,const unsigned int),
  IsTainted(const Image *),
  PingImage(ImageInfo *,unsigned int *,unsigned int *),
  PlasmaImage(Image *,const SegmentInfo *,int,int),
  UncondenseImage(Image *),
  WriteAVSImage(const ImageInfo *image_info,Image *image),
  WriteBMPImage(const ImageInfo *image_info,Image *image),
  WriteCMYKImage(const ImageInfo *image_info,Image *image),
  WriteEPTImage(const ImageInfo *image_info,Image *image),
  WriteFAXImage(const ImageInfo *image_info,Image *image),
  WriteFITSImage(const ImageInfo *image_info,Image *image),
  WriteFPXImage(const ImageInfo *image_info,Image *image),
  WriteGIFImage(const ImageInfo *image_info,Image *image),
  WriteGRAYImage(const ImageInfo *image_info,Image *image),
  WriteHDFImage(const ImageInfo *image_info,Image *image),
  WriteHISTOGRAMImage(const ImageInfo *image_info, Image *image),
  WriteHTMLImage(const ImageInfo *image_info,Image *image),
  WriteICCImage(const ImageInfo *image_info,Image *image),
  WriteIPTCImage(const ImageInfo *image_info,Image *image),
  WriteImage(const ImageInfo *,Image *),
  WriteJBIGImage(const ImageInfo *image_info,Image *image),
  WriteJPEGImage(const ImageInfo *image_info,Image *image),
  WriteLOGOImage(const ImageInfo *image_info,Image *image),
  WriteMAPImage(const ImageInfo *image_info,Image *image),
  WriteMATTEImage(const ImageInfo *image_info,Image *image),
  WriteMIFFImage(const ImageInfo *image_info,Image *image),
  WriteMONOImage(const ImageInfo *image_info,Image *image),
  WriteMTVImage(const ImageInfo *image_info,Image *image),
  WriteNTImage(const ImageInfo *,Image *),
  WritePCDImage(const ImageInfo *image_info,Image *image),
  WritePCLImage(const ImageInfo *image_info,Image *image),
  WritePCXImage(const ImageInfo *image_info,Image *image),
  WritePDFImage(const ImageInfo *image_info,Image *image),
  WritePICTImage(const ImageInfo *image_info,Image *image),
  WritePNGImage(const ImageInfo *image_info,Image *image),
  WritePNMImage(const ImageInfo *image_info,Image *image),
  WritePREVIEWImage(const ImageInfo *image_info,Image *image),
  WritePS2Image(const ImageInfo *image_info,Image *image),
  WritePSDImage(const ImageInfo *image_info,Image *image),
  WritePSImage(const ImageInfo *image_info,Image *image),
  WriteRGBImage(const ImageInfo *image_info,Image *image),
  WriteSGIImage(const ImageInfo *image_info,Image *image),
  WriteSUNImage(const ImageInfo *image_info,Image *image),
  WriteTGAImage(const ImageInfo *image_info,Image *image),
  WriteTIFFImage(const ImageInfo *image_info,Image *image),
  WriteTXTImage(const ImageInfo *image_info,Image *image),
  WriteUILImage(const ImageInfo *image_info,Image *image),
  WriteUYVYImage(const ImageInfo *image_info,Image *image),
  WriteVICARImage(const ImageInfo *image_info,Image *image),
  WriteVIFFImage(const ImageInfo *image_info,Image *image),
  WriteXBMImage(const ImageInfo *image_info,Image *image),
  WriteXImage(const ImageInfo *image_info,Image *image),
  WriteXPMImage(const ImageInfo *image_info,Image *image),
  WriteXWDImage(const ImageInfo *image_info,Image *image),
  WriteYUVImage(const ImageInfo *image_info,Image *image);

extern Export void
  AllocateNextImage(const ImageInfo *,Image *),
  AnnotateImage(Image *,const AnnotateInfo *),
  CloseImage(Image *),
  CoalesceImages(Image *),
  ColorFloodfillImage(Image *,const RunlengthPacket *,Image *,const int x,
    const int y,const PaintMethod),
  ColorizeImage(Image *,const char *,const char *),
  CommentImage(Image *,const char *),
  CompositeImage(Image *,const CompositeOperator,Image *,const int,const int),
  CompressColormap(Image *),
  CondenseImage(Image *),
  ContrastImage(Image *,const unsigned int),
  CycleColormapImage(Image *,const int),
  DescribeImage(Image *,FILE *,const unsigned int),
  DestroyAnnotateInfo(AnnotateInfo *),
  DestroyImage(Image *),
  DestroyImageInfo(ImageInfo *),
  DestroyImages(Image *),
  DestroyMontageInfo(MontageInfo *),
  DrawImage(Image *,const AnnotateInfo *),
  EqualizeImage(Image *),
  GammaImage(Image *,const char *),
  GetAnnotateInfo(const ImageInfo *,AnnotateInfo *),
  GetImageInfo(ImageInfo *),
  GetMontageInfo(MontageInfo *),
  GetPixels(const Image *,float *,float *,float *,float *),
  LabelImage(Image *,const char *),
  LayerImage(Image *,const LayerType),
  MatteFloodfillImage(Image *,const RunlengthPacket *,const unsigned int,
    const int x,const int y,const PaintMethod),
  MatteImage(Image *),
  ModulateImage(Image *,const char *),
  MogrifyImage(const ImageInfo *,const int,char **,Image **),
  MogrifyImages(const ImageInfo *,const int,char **,Image **),
  NegateImage(Image *,const unsigned int),
  NormalizeImage(Image *),
  OpaqueImage(Image *,const char *,const char *),
  OpenImage(const ImageInfo *,Image *,const char *),
  RaiseImage(Image *,const RectangleInfo *,const int),
  RGBTransformImage(Image *,const ColorspaceType),
  SetImage(Image *),
  SetImageInfo(ImageInfo *,const unsigned int),
  SignatureImage(Image *),
  SolarizeImage(Image *,const double),
  SortColormapByIntensity(Image *),
  SyncImage(Image *),
  TextureImage(Image *,Image *),
  ThresholdImage(Image *,const double),
  TransformHSL(const Quantum,const Quantum,const Quantum,double *,double *,
    double *),
  TransformImage(Image **,const char *,const char *),
  TransformRGBImage(Image *,const ColorspaceType),
  TransparentImage(Image *,const char *);

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

#endif
