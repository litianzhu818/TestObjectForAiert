

#define KEY_RECORD_ID                 @"RecordId"
#define KEY_DEVICE_ID                 @"DeviceId"
#define KEY_START_TIME                @"StartTime"
#define KEY_END_TIME                  @"EndTime"
#define KEY_FILE_EXT                  @"FileExt"
#define KEY_CHANNEL                   @"Channel"
#define KEY_TYPE                      @"Type"

#import "ZMRecorderFileIndex.h"

@interface ZMRecorderFileIndex ()
@property (copy, nonatomic) NSString *recorderId;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *deviceId;
@property (nonatomic) NSInteger channel;
@property (copy, nonatomic) NSString *fileExt;
@property (nonatomic) NSInteger type;

@end

@implementation ZMRecorderFileIndex

- (id)initWithRecordDeviceId:(NSString *)devId
                     channel:(NSInteger)channel
                   startTime:(NSString *)startTime
               fileExtension:(NSString *)fileExt
                        type:(NSInteger)type

{
    if (self = [super init]) {
        self.deviceId = devId;
        self.startTime = startTime;
        self.endTime = startTime;
        self.channel = channel;
        self.fileExt = fileExt;
        self.type = type;
        
        self.recorderId = [NSString stringWithFormat:@"%@_%d_%@_%@",
                           devId,
                           channel,
                           startTime,
                           fileExt];
    }
    
    return self;
}

- (NSUInteger)hash
{
    return self.deviceId.hash^self.startTime.hash^self.endTime.hash^self.fileExt.hash;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.recorderId forKey:KEY_RECORD_ID];
    [aCoder encodeObject:self.deviceId forKey:KEY_DEVICE_ID];
    [aCoder encodeObject:self.startTime forKey:KEY_START_TIME];
    [aCoder encodeObject:self.endTime forKey:KEY_END_TIME];
    [aCoder encodeObject:self.fileExt forKey:KEY_FILE_EXT];
    [aCoder encodeInteger:self.channel forKey:KEY_CHANNEL];
    [aCoder encodeInteger:self.type forKey:KEY_TYPE];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.recorderId = [aDecoder decodeObjectForKey:KEY_RECORD_ID];
        self.deviceId = [aDecoder decodeObjectForKey:KEY_DEVICE_ID];
        self.startTime = [aDecoder decodeObjectForKey:KEY_START_TIME];
        self.endTime = [aDecoder decodeObjectForKey:KEY_END_TIME];
        self.fileExt = [aDecoder decodeObjectForKey:KEY_FILE_EXT];
        self.channel = [aDecoder decodeIntegerForKey:KEY_CHANNEL];
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{recordId:%@, deviceId : %@, deviceChannel: %d, startTime : %@, endTime: %@, fileExt: %@ type: %d}",
            self.recorderId,
            self.deviceId,
            self.channel,
            self.startTime,
            self.endTime,
            self.fileExt,
            self.type];
}
@end
