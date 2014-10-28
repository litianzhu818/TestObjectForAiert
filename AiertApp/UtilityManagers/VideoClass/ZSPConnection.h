

#import <Foundation/Foundation.h>
@protocol ZSPConnectionDelegate;

@interface ZSPConnection : NSObject

@property (weak, nonatomic) id<ZSPConnectionDelegate> zspConnectionDelegate;

- (id)initWithDelegate:(id<ZSPConnectionDelegate>)delegate;


- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                 deviceIP:(NSString *)ip
               devicePort:(NSUInteger)port;

- (void)startDisplayWithDeviceIp:(NSString *)deviceIp
                            port:(NSInteger)port
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)mediaType
                   isLocalDevice:(BOOL)bLocal;

- (void)stopRealPlay;

- (void)reStartRealPlay;

- (void)changeChannel:(NSInteger)destChannel;

- (void)changeStream:(NSInteger)destMediaType;

- (void)openSound:(BOOL)bOpen;

- (void)openMic:(BOOL)bOpen;

- (void)closeCommandSocket;

- (void)sendMicDataToDevice:(BytePtr)pBuffer length:(int)nBufferLen;

@end

@protocol ZSPConnectionDelegate <NSObject>
//- (void)didDecodeOneImage:(UIImage *)image;
//- (void)releaseCurrentQueue;
//- (void)setStatusAfterRelease:(NSNumber *)num;
//- (void)startCurrentQueue;
//- (void)channelChanged;
//- (void)didReceiveDeviceInfo:(NSDictionary *)devDict;
////- (void)didReciveLargeParam:(WifiNetworkInfo *)aWifiNetworkInfo;
//- (void)didReciveWifiApList:(NSArray *)aWifiList selectedIndex:(NSInteger)selectedIndex;
//- (void)didSetWifiApSuccessful;
//- (void)didSetWifiStatusSuccessful;
//- (void)didSetWifiInfoSuccessful;
//- (void)didSetUserPasswordSuccessful;


- (void)didLoginSuccess;
- (void)didReadAudioData:(NSData *)data;
- (void)didReadVideoData:(NSData *)data;
- (void)didReadRawData:(NSData *)data tag:(NSInteger)tag;
- (void)didReadAudioResponse:(NSInteger)code;
- (void)didReadMicResponse:(NSInteger)code;
- (void)didReadDataTimeOut;
- (void)didDisconnect;
- (void)didConnected;

@end
