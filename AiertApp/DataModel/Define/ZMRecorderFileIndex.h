

#import <Foundation/Foundation.h>

@interface ZMRecorderFileIndex : NSObject<NSCoding>
@property (copy, nonatomic, readonly) NSString *recorderId;
@property (copy, nonatomic, readonly) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic, readonly) NSString *deviceId;
@property (nonatomic, readonly) NSInteger channel;
@property (copy, nonatomic, readonly) NSString *fileExt;
@property (nonatomic, readonly) NSInteger type;           // 0:picture 1:video

- (id)initWithRecordDeviceId:(NSString *)devId 
                     channel:(NSInteger)channel 
                   startTime:(NSString *)startTime
               fileExtension:(NSString *)fileExt
                        type:(NSInteger)type;
@end
