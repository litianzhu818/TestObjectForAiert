

#import <Foundation/Foundation.h>

@protocol P2pConnectionDelegate;

@interface P2PConnection : NSObject

@property(weak ,nonatomic) id<P2pConnectionDelegate> p2pDelegate;


- (id)initWithDelegate:(id<P2pConnectionDelegate>)delegate;

- (BOOL)isUPNPSupport:(NSString *)strDevice;
- (BOOL)login:(NSString *)strUserName password:(NSString *)strPassword;
- (BOOL)changePwd:(NSString *)strUserName password:(NSString *)strPassword;
- (BOOL)requestStream:(NSString *)strDeviceID
              channel:(NSInteger)iChannel
           streamType:(NSInteger)stream_type                // @stream_type 0 QVGA , 1 VGA , 2 720P
                isP2p:(BOOL)bP2p;                           // @bP2p YES : p2p NO: 中转
- (void)stopRealPlay;
- (BOOL)enableSound:(BOOL)bOpen;
- (BOOL)enableTalk:(BOOL)bTalk;
- (void)sendTalkData:(BytePtr)pData length:(int)iSize;
- (BOOL)changeStream:(NSInteger)iChannel
           mediaType:(NSInteger)iNewMediaType
           operation:(NSInteger)operation;
@end

@protocol P2pConnectionDelegate <NSObject>

- (void)didGetUPNPSupportInfoWithTag:(NSInteger)tag param:(id)param;
- (void)didRecvVideoFrameData:(NSInteger)iType streamData:(char *)pData size:(NSInteger)iSize;
- (void)didRecvAudioFrameData:(char *)pData size:(NSInteger)iSize;
- (void)didRecvRawData:(char *)pData size:(NSInteger)iSize tag:(NSInteger)tag;
- (void)didRecvStreamStatus:(int)iStatus;

@end