//
//  Video.h
//  cms

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
@class YUVFrame;
@interface VideoFrameExtractor : NSObject {
	AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVCodecParserContext* pCodecParser;
    AVPacket packet;
    AVCodec *pCodec;
    AVPicture picture;
}

- (YUVFrame *)currentFrame;
- (BOOL)stepFrame:(BytePtr) pBuffer length: (int)nBufferLen;
+ (id)creatVideoFrameExtractor;
+ (void)releaseVideoFrameExtractor:(VideoFrameExtractor *)video;

- (UIImage *)convertFrameToRGB;
@end
