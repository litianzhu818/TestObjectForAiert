

#import <Foundation/Foundation.h>
#import "ZSPConnection.h"
#import "P2PManager.h"
#import "AiertDeviceInfo.h"

@interface LibCoreWrap : NSObject<ZSPConnectionDelegate,P2PManagerDelegate>

+ (LibCoreWrap *)sharedCore;

- (void)closeConnection;
/**
 * @brief initialize library.
 */
- (int)initialize;

/**
 * @brief uninitialize library.
 */
- (void)unInitialize;

/**
 * @brief register event observer.
 */
- (void)registerEventObserver:(id)observer;

/**
 * @brief unregister event observer.
 */
- (void)unRegisterEventObserver:(id)observer;

/**
 * @brief unregister all system observer.
 */
- (void)unRegisterAllEventObservers;

/**
 * @brief request to establish a real-time streaming for preview.
 */
- (int)startRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)media_type
                        userName:(NSString *)username
                        password:(NSString *)password
                         timeout:(NSInteger)timeout;

/**
 * @brief pause real-time streaming, not release connection.
 */
- (void)pauseRealPlayWithDeviceId:(NSString *)device_id
                          channel:(NSInteger)channel;

/**
 * @brief stop real-time streaming and release connection.
 */
- (void)stopRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel;

/**
 * @brief change channel.
 */
- (void)changeChannel:(NSInteger)dstChannel;

/**
 * @brief change stream.
 */
- (void)changeStream:(NSInteger)dstMediaType;


/**
 * @brief register channel stream observer
 */
- (int)registerStreamObserverWithDeviceId:(NSString *)device_id
                                  channel:(NSInteger)channel
                           streamObserver:(id) observer;

/**
 * @brief unregister channel signle observer
 */
- (int)unRegisterStreamObserverWithDeviceId:(NSString *)device_id
                                    channel:(NSInteger)channel
                             streamObserver:(id) observer;
/**
 * @brief unregister channel all observer's
 */
- (int)unRegisterAllStreamObserverWithDeviceId:(NSString *)device_id
                                       channel:(NSInteger)channel;

/**
 * @brief open sound.
 */
- (int)openSoundWithDeviceId:(NSString *)device_id
                     channel:(NSInteger)channel;

/**
 * @brief close sound.
 */
- (int)closeSoundWithDeviceId:(NSString *)device_id
                      channel:(NSInteger)channel;

/**
 * @brief start talk.
 */
- (int)startTalkWithDeviceId:(NSString *)device_id
                     channel:(NSInteger)channel;

/**
 * @brief stop talk.
 */
- (int)stopTalkWithDeviceId:(NSString *)device_id
                    channel:(NSInteger)channel;

/**
 * @brief send talk audio data.
 */
- (int)talkSendDataWithDeviceId:(NSString *)device_id
                        channel:(NSInteger)channel
                           data:(BytePtr)pBuffer
                         length:(int)nBufferLen;

/**
 * @brief login.
 */
- (int)loginWithDeviceId:(NSString *)device_id
                 channel:(NSInteger)channel
                userName:(NSString *)username
                password:(NSString *)password;

/**
 * @brief set password.
 */
- (int)setPassWordWithDeviceId:(NSString *)device_id
                       channel:(NSInteger)channel
                      userName:(NSString *)username
                      password:(NSString *)password;

- (id)currentFrame;

- (void)setMirrorUpDown;
- (void)setMirrorLeftRight;
- (void)stopTurnCamera;

- (void)setCameraBrightness:(NSInteger)Brightness;
- (void)setCameraContrast:(NSInteger)Contrast;
- (void)setCameraSaturation:(NSInteger)Saturation;
- (void)setCamseraDefauleValue;

- (void)setAudioStart:(BOOL)start;

- (void)startTurnCameraWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType;

@end

@protocol StreamObserverProtocol

- (void)didReceiveRawData:(NSData *)data tag:(NSInteger)tag;
- (void)didReceiveImageData:(id)data;
- (void)didReceiveAudioData:(NSData *)data;
- (void)didStartPlayWithDeviceID:(NSString *)deviceID;
- (void)didStopPlayWithDeviceID:(NSString *)deviceID;
- (void)didFailedPlayWithDeviceID:(NSString *)deviceID;

@end

@protocol EventObserverProtocol
- (void)didReceiveEvent:(NSInteger)code
                content:(NSString *)content
               deviceId:(NSString *)deviceId
                channel:(NSInteger)channel;
@end

