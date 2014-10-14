

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "AppData.h"
#import "ZMRecorderFileIndex.h"

@interface ZMRecorderFileIndexManage : NSObject

+ (id)recorderFileIndexs;
+ (BOOL)addRecorderFileIndex:(id)recorderFileIndex;
+ (BOOL)removeRecorderFileIndex:(id)recorderId;
+ (BOOL)writeRecorderFileIndex:(id)dic;

+ (BOOL)saveScreenShotImage:(id)image 
                   deviceId:(NSString *)devId 
                    channel:(NSInteger)channel;
@end
