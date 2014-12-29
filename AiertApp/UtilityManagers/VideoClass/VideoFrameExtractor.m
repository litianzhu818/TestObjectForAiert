//
//  Video.m
//  cms
//

#import "VideoFrameExtractor.h"
#import "YUVFrame.h"

@interface VideoFrameExtractor (private)
//- (void)convertFrameToRGB;
- (void)setupScaler;
@end

@implementation VideoFrameExtractor

static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height)
{
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength:(width * height)];
#warning There is a bug here:the md mybe nil here    
    if (!md) return nil;
    
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {

        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

+ (id)creatVideoFrameExtractor
{
    @synchronized(self)
    {
        DLog(@"before creat !");
        VideoFrameExtractor *video = [[VideoFrameExtractor alloc]init];
        DLog(@"after creat !");
        return video;
    }
}
+ (void)releaseVideoFrameExtractor:(VideoFrameExtractor *)video
{
    @synchronized(self)
    {
        
        video = nil;
    }
}

- (YUVFrame *)currentFrame {
	if (!pFrame->data[0]) return nil;

    YUVFrame *yuvFrame = [[YUVFrame alloc] init];

    yuvFrame.luma = copyFrameData(pFrame->data[0],
                                  pFrame->linesize[0],
                                  pCodecCtx->width,
                                  pCodecCtx->height);
    
    yuvFrame.chromaB = copyFrameData(pFrame->data[1],
                                     pFrame->linesize[1],
                                     pCodecCtx->width / 2,
                                     pCodecCtx->height / 2);
    
    yuvFrame.chromaR = copyFrameData(pFrame->data[2],
                                     pFrame->linesize[2],
                                     pCodecCtx->width / 2,
                                     pCodecCtx->height / 2);
    
    yuvFrame.width = pCodecCtx->width;
    yuvFrame.height = pCodecCtx->height;
    
	return yuvFrame;
}
- (id)init
{
	if (!(self=[super init])) return nil;
    
    // Register all formats and codecs
    av_register_all();
    
    // Find the decoder for the video stream
    pCodec = avcodec_find_decoder(CODEC_ID_H264);
    if(pCodec == NULL)
        goto initError; // Codec not found

    // Allocate video frame
    pFrame = avcodec_alloc_frame();
    pCodecCtx = avcodec_alloc_context3(pCodec);
    
    if(NULL == pCodecCtx)
        goto initError;
    
    if(pCodec->capabilities & CODEC_CAP_TRUNCATED)
    {
        pCodecCtx->flags |= CODEC_FLAG_TRUNCATED;
    }   
    
    // Open codec
    if(avcodec_open2(pCodecCtx, pCodec,nil)<0)
        goto initError; // Could not open codec
    
	pCodecParser = av_parser_init(CODEC_ID_H264);
    av_init_packet(&packet);
    
	return self;
	
initError:
	return nil;
}

- (void)dealloc {
    
    // Free the YUV frame
    av_free(pFrame);

    // Close the codec
    if (pCodecCtx) 
        avcodec_close(pCodecCtx);

    av_free(pCodecCtx);

	av_free_packet(&packet);

    av_free(pCodecParser);
    
    avpicture_free(&picture);
    
}

- (BOOL)stepFrame:(BytePtr)pBuffer length:(int)nBufferLen {
    
	BytePtr pDataFlag = pBuffer;
	int bufSize = nBufferLen;
    int nFrameFinished = 0;
    
	while(bufSize > 0) {
        
		int size = 0;
		uint8_t * pBuf = NULL;
		int nLen = av_parser_parse2(pCodecParser,
                                    pCodecCtx,
                                    &pBuf,
                                    &size,
                                    (uint8_t*)pDataFlag,
                                    bufSize,
                                    AV_NOPTS_VALUE,
                                    AV_NOPTS_VALUE,
                                    AV_NOPTS_VALUE);
        
		bufSize -= nLen;
		pDataFlag += nLen;
		
		if(size != 0) {
			packet.data = pBuf;
			packet.size = size;
			avcodec_decode_video2(pCodecCtx, pFrame, &nFrameFinished, &packet);
		}
        // Free the packet
        av_free_packet(&packet);
	}
    return nFrameFinished !=0;
}

- (UIImage *)convertFrameToRGB {
    
    if (!pFrame->data[0]) return nil;
    
    struct SwsContext * scxt420 = sws_getContext(pCodecCtx->width,
                                                 pCodecCtx->height,
                                                 pCodecCtx->pix_fmt,
                                                 pCodecCtx->width,
                                                 pCodecCtx->height,
                                                 PIX_FMT_RGB24,
                                                 SWS_POINT,
                                                 NULL,
                                                 NULL,
                                                 NULL);
    if (scxt420 == NULL) {
        return nil;
    }

    
    avpicture_alloc(&picture, PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);

    sws_scale (scxt420,
               (const uint8_t **)pFrame->data,
               pFrame->linesize,
               0,
               pCodecCtx->height,
			   picture.data,
               picture.linesize);
    
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                 picture.data[0],
                                                 picture.linesize[0]*pCodecCtx->height,
                                                 kCFAllocatorNull);
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGImageRef cgImage = CGImageCreate(pCodecCtx->width,
									   pCodecCtx->height,
									   8,
									   24,
									   picture.linesize[0],
									   colorSpace,
									   bitmapInfo,
									   provider,
									   NULL,
									   NO,
									   kCGRenderingIntentDefault);
	CGColorSpaceRelease(colorSpace);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGDataProviderRelease(provider);
	CFRelease(data);
    
	return image;
}
@end
