//
//  P2PManager.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/31.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TURN_STOP       0
#define TURN_UP         1
#define TURN_DOWN       2
#define TURN_LEFT       3
#define TURN_RIGHT      4

#define TURN_LEFT_RIGHT 5
#define TURN_UP_DOWN    6

#define DEFAULT_SETTING_VALUE 128

typedef NS_ENUM(NSUInteger, CONNECT_TYPE){
    
    CONNECT_P2P_TYPE = 0,   //The p2p connect type
    CONNECT_RELAY_TYPE,     //The relay connect type
    CONNECT_LAN_TYPE        //The lan connect type
};

typedef NS_ENUM(NSUInteger, CAMERA_TURN_TYPE){
    
    CAMERA_TURN_TYPE_STOP = 0,
    CAMERA_TURN_TYPE_UP = 1,
    CAMERA_TURN_TYPE_DOWN = 2,
    CAMERA_TURN_TYPE_LEFT = 3,
    CAMERA_TURN_TYPE_RIGHT = 4,
    CAMERA_TURN_TYPE_UP_DOWN = 5,
    CAMERA_TURN_TYPE_LEFT_RIGHT = 6
};

typedef NS_ENUM(NSUInteger, CAMERA_PLAY_TYPE){
    
    CAMERA_PLAY_TYPE_QVGA = 0,
    CAMERA_PLAY_TYPE_VGA = 1,
    CAMERA_PLAY_TYPE_720 = 2
};

typedef void(^ConnectStatusBlock)(AiertDeviceInfo *device, BOOL connectSucceed, NSError *error);

@protocol P2PManagerDelegate;

@interface P2PManager : NSObject

@property (weak, nonatomic)  id<P2PManagerDelegate> delegate;

+ (P2PManager *)sharedInstance;

- (instancetype)initWithDelegate:(id<P2PManagerDelegate>)delegate;
- (void)removeDelegate;

- (dispatch_queue_t)p2pVideoPlayManagerQueue;
- (void *)p2pVideoPlayManagerQueueTag;


- (void)startWithSID:(int)SID;
/**
 *  用设备id连接进行网络连接
 *
 *  @param deviceID 设备ID
 */
- (void)checkConnectTypeWithDeviceID:(NSString *)deviceID;
- (void)startIpcamStream:(int)avindex withPlayType:(CAMERA_PLAY_TYPE)playType;

- (void)checkConnectTypeWithDeviceInfo:(AiertDeviceInfo *)device connectStatusBlock:(ConnectStatusBlock)block;

- (void)closeConnection;

- (void)setMirrorUpDown;
- (void)setMirrorLeftRight;
- (void)stopTurnCamera;
- (void)startTurnCameraWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType;
- (void)turnWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType;

- (void)setCameraBrightness:(NSInteger)Brightness;
- (void)setCameraContrast:(NSInteger)Contrast;
- (void)setCameraSaturation:(NSInteger)Saturation;
- (void)setCameraDefauleValue;

- (void)setAudioStart:(BOOL)start;

- (void)sendTalkData:(BytePtr)pData length:(int)iSize;

@end


@protocol P2PManagerDelegate <NSObject>

@optional

- (void)p2pManager:(P2PManager *)p2pManager didConnectDeviceID:(NSString *)deviceID withType:(CONNECT_TYPE)connectType ip:(NSString *)ip port:(NSUInteger)port sid:(int)sid;
- (void)p2pManager:(P2PManager *)p2pManager didFailedConnectDeviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didFailedStartPlayWithDeviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didReadAudioData:(NSData *)data;
- (void)p2pManager:(P2PManager *)p2pManager didReadVideoData:(NSData *)data;
- (void)p2pManager:(P2PManager *)p2pManager didReadRawData:(NSData *)data tag:(NSInteger)tag;
- (void)p2pManager:(P2PManager *)p2pManager didReadAudioResponse:(NSInteger)code;
- (void)p2pManager:(P2PManager *)p2pManager didReadMicResponse:(NSInteger)code;

- (void)p2pManager:(P2PManager *)p2pManager didStartTryToPlayerWithDeviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didStartPlayWithDEviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didStopPlayWithDEviceID:(NSString *)deviceID;

- (void)p2pManager:(P2PManager *)p2pManager didPlayTimeoutWithEviceID:(NSString *)deviceID;

- (void)didReadDataTimeOut;
- (void)didDisconnect;
- (void)didConnected;
- (void)didLoginSuccess;

@end
