//
//  Utilities.h
//
#import "BasicDefine.h"

//#define myTest      1

@interface Utilities : NSObject
+ (NSString *)documentsPath:(NSString *)fileName;
+ (NSString *)bundlePath:(NSString *)fileName;
+ (NSString *)documentsPathWithFolder:(NSString *)folderPath
                             fileName:(NSString *)fileName;
+ (BOOL)checkRegFormat:(NSString *)sourceString
         patternString:(NSString *)patternString;
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteService:(NSString *)service;
+ (NSString *)absolutePathForResource:(NSString *)name 
                               ofType:(NSString *)type;
+ (NSString *)carrierName;
+ (NSString *)deviceName;

+ (id)persistedInfoFromFolderPath:(NSString *)path
                         fileName:(NSString *)fileName
                              key:(NSString *)infoKey;
+ (BOOL)persistentInfo:(id)info
            folderPath:(NSString *)path
              fileName:(NSString *)fileName
                   key:(NSString *)infoKey;

+ (void)setMyViewControllerOrientation:(BOOL)verticalScreen
                           Orientation:(UIInterfaceOrientation)orientation;

+ (NSString *)dateToStringWithFormat:(NSString *)format date:(NSDate *)date;
+ (NSDate *)stringToDateWithFormat:(NSString *)format dateString:(NSString *)string;

//图片缩微图
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image Width:(float)width Height:(float)hight;
@end
