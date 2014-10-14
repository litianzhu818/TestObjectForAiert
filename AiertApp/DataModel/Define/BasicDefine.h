

#ifndef Aiert_BasicDefine_h
#define Aiert_BasicDefine_h

//IOS7_OR_LATER
#define IOS7_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )


#define kRegEmail             @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b" // 检测email合法
#define kRegAllLeters         @"^[A-Za-z]+$"                                                     // 全字母
#define kRegAllNumbers        @"^[0-9]\\d*$"                                                     // 全数字
#define kRegLetterNumOrLine   @"^\\w+$"                                                          // 数字、26个英文字母或者下划线组成的字符串
#define kRegChineseCharacter  @"^[u4e00-u9fa5],{0,}$"                                            // 中文字符
#define kRegFirstLine         @"^_"                                                              // 首字母下划线
#define kRegDeviceIdFormat    @"^(\\d){10,15}$"

//Video Quality Type - LD SD HD
typedef NS_ENUM(NSInteger, VideoQualityType) {
    VideoQualityTypeLD = 0,
    VideoQualityTypeSD = 1,
    VideoQualityTypeHD = 2
};

//Wifi Status - Connected? Password?
typedef NS_ENUM(NSInteger, DeviceWifiStatus) {
    DeviceWifiStatusDisconnetedWithPassword    = 0,
    DeviceWifiStatusDisconnetedWithoutPassword = 1,
    DeviceWifiStatusConnetedWithPassword       = 2,
    DeviceWifiStatusConnetedWithoutPassword    = 3
};

//Decoder Type - Hardware or OpenGL
typedef NS_ENUM(NSInteger, DecoderType) {
    DecoderTypeHard = 0,
    DecoderTypeOpenGLES = 1
};

typedef NS_ENUM(uint, CameraState) {
   
    CameraStateActive                    = 1<<0,
    
    CameraStateConnected                 = 1<<1,
    CameraStateLogin                     = 1<<2,
    CameraStateVideoPlaying              = 1<<3,
    CameraStateAudioPlaying              = 1<<4,
    CameraStateMicOpening                = 1<<5,
    CameraStateRecording                 = 1<<6
        
};

typedef NS_ENUM(NSInteger, CameraNetworkState) {
    
    CameraNetworkStateUnconnected = 0,
    CameraNetworkStateUpnpQuerying,
    CameraNetworkStateConnecting,
    
    CameraNetworkStateUpnpConnected,
    CameraNetworkStateUpnpConnectFailed,
    CameraNetworkStateUpnpRecvFailed,

    CameraNetworkStateP2pConnected,
    CameraNetworkStateP2pConnectFailed,
    CameraNetworkStateP2pRecvFailed,

    CameraNetworkStateTransmitConnected,
    CameraNetworkStateTransmitConnectFailed,
    CameraNetworkStateTransmitRecvFailed,
    
    CameraNetworkStateLocalConnected,
    CameraNetworkStateLocalConnectFailed,
    CameraNetworkStateLocalRecvFailed,

    CameraNetworkStateAllConnectFailed

};

typedef NS_ENUM(NSInteger, LibCoreEventCode)
{
    LibCoreEventCodePlayStoped = 0,
    LibCoreEventCodeAudioResponseSuccess,
    LibCoreEventCodeAudioResoponseFailed,
    LibCoreEventCodeOpenMicSuccess,
    LibCoreEventCodeMicResponseBusy,
    LibCoreEventCodeMicResponseFailed
};
typedef NS_ENUM(NSInteger, UpnpQueryResult)
{
    UpnpQueryResultSupport = 0,
    UpnpQueryResultNotSupport,
    UpnpQueryFailure
};

typedef NS_ENUM(NSInteger, RawDataTag)
{
    RawDataTagHeader = 0,
    RawDataTagVideoBody,
    RawDataTagAudioBody
};

typedef NS_ENUM(NSInteger, StoragePlayBottomType)
{
    StoragePlayBottomTypeImage = 0,
    StoragePlayBottomTypeVideo,
};

typedef NS_ENUM(NSInteger, PlayBottomType)
{
    PlayBottomTypeVideo = 0,
    PlayBottomTypeGrab,
    PlayBottomTypeTalk,
    PlayBottomTypeSound,
    PlayBottomTypeQuality
};

#endif
