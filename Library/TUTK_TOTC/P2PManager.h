//
//  P2PManager.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/31.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CONNECT_TYPE){
    
    CONNECT_P2P_TYPE = 0,   //The p2p connect type
    CONNECT_RELAY_TYPE,     //The relay connect type
    CONNECT_LAN_TYPE        //The lan connect type
};

@protocol P2PManagerDelegate;

@interface P2PManager : NSObject

@property (weak, nonatomic)  id<P2PManagerDelegate> delegate;

+ (P2PManager *)sharedInstance;

- (instancetype)initWithDelegate:(id<P2PManagerDelegate>)delegate;
- (void)removeDelegate;

- (dispatch_queue_t)p2pManagerQueue;
- (void *)p2pManagerQueueTag;

/**
 *  用设备id连接进行网络连接
 *
 *  @param deviceID 设备ID
 */
- (void)startWithSID:(int)SID;
- (void)checkConnectTypeWithDeviceID:(NSString *)deviceID;
- (void)start:(NSString *)UID;

- (void)closeConnection;

@end


@protocol P2PManagerDelegate <NSObject>

@optional

- (void)p2pManager:(P2PManager *)p2pManager didConnectDeviceID:(NSString *)deviceID withType:(CONNECT_TYPE)connectType ip:(NSString *)ip port:(NSUInteger)port sid:(int)sid;
- (void)p2pManager:(P2PManager *)p2pManager didReadAudioData:(NSData *)data;
- (void)p2pManager:(P2PManager *)p2pManager didReadVideoData:(NSData *)data;
- (void)p2pManager:(P2PManager *)p2pManager didReadRawData:(NSData *)data tag:(NSInteger)tag;
- (void)p2pManager:(P2PManager *)p2pManager didReadAudioResponse:(NSInteger)code;
- (void)p2pManager:(P2PManager *)p2pManager didReadMicResponse:(NSInteger)code;

- (void)p2pManager:(P2PManager *)p2pManager didStartTryToPlayerWithDeviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didStartPlayWithDEviceID:(NSString *)deviceID;
- (void)p2pManager:(P2PManager *)p2pManager didStopPlayWithDEviceID:(NSString *)deviceID;

- (void)didReadDataTimeOut;
- (void)didDisconnect;
- (void)didConnected;
- (void)didLoginSuccess;

@end
