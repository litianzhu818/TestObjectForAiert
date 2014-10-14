//
//  Utilities.m
//

#import "Utilities.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@implementation Utilities

+ (NSString *)documentsPath:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString *)bundlePath:(NSString *)fileName {
    
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentsPathWithFolder:(NSString *)folderPath
                             fileName:(NSString *)fileName {
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *fullPath;
    if (folderPath) {
        fullPath = [docPath stringByAppendingPathComponent:folderPath];
        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSAssert(bo,@"创建目录失败");

    }else
    {
        fullPath = docPath;
    }
    
	return [fullPath stringByAppendingPathComponent:fileName];
}

+ (NSString *)absolutePathForResource:(NSString *)name ofType:(NSString *)type
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Res" ofType:@"bundle"]];
    return [bundle pathForResource:name ofType:type];
}

#pragma mark - checkRegFormat
+ (BOOL)checkRegFormat:(NSString *)sourceString patternString:(NSString *)patternString
{
    NSError *error = NULL;
    //定义正则表达式
    NSRegularExpression *regexQrCode = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:&error];
    //使用正则表达式匹配字符
    NSTextCheckingResult *isMatchQrCode = [regexQrCode firstMatchInString:sourceString options:0 range:NSMakeRange(0, [sourceString length])];
    
    return isMatchQrCode ? YES : NO;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            DLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)deleteService:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}


#pragma mark - CarrierInfo

// Carrier Name
+ (NSString *)carrierName {
    // Get the carrier name
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier name
        NSString *CarrierName = [Carrier carrierName];
        
        // Check to make sure it's valid
        if (CarrierName == nil || CarrierName.length <= 0) {
            // Return unknown
            return @"";
        }
        
        // Return the name
        return CarrierName;
    }
    @catch (NSException *exception) {
        // Error finding the name
        return nil;
    }
}

+ (NSString *)deviceName {
    // Get the current device name
    if ([[UIDevice currentDevice] respondsToSelector:@selector(name)]) {
        // Make a string for the device name
        NSString *deviceName = [[UIDevice currentDevice] name];
        // Set the output to the device name
        return deviceName;
    } else {
        // Device name not found
        return nil;
    }
}

#pragma mark - Get PersistentInfo
+ (id)persistedInfoFromFolderPath:(NSString *)path
                         fileName:(NSString *)fileName
                              key:(NSString *)infoKey
{
    NSString *fullPath = [Utilities documentsPathWithFolder:path fileName:fileName];
    DLog(@"dataPath: %@",fullPath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSData *data;
        NSKeyedUnarchiver *unarchiver;
        data = [[NSData alloc] initWithContentsOfFile:fullPath];
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableDictionary *dictionary = [unarchiver decodeObjectForKey:infoKey];
        [unarchiver finishDecoding];
        
        return [dictionary objectForKey:infoKey];
    }
    return nil;
}
#pragma mark - PersistentInfo
+ (BOOL)persistentInfo:(id)info
            folderPath:(NSString *)path
              fileName:(NSString *)fileName
                   key:(NSString *)infoKey
{
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:info forKey:infoKey];
    
    NSMutableData *data;
    NSKeyedArchiver *archiver;
    data = [NSMutableData data];
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    // Customize archiver here
    [archiver encodeObject:dictionary forKey:infoKey];
    [archiver finishEncoding];
    
    DLog(@"write path : %@",[Utilities documentsPathWithFolder:path fileName:fileName]);
    
    return [data writeToFile:[Utilities documentsPathWithFolder:path fileName:fileName] atomically:YES];
}

+ (void)setMyViewControllerOrientation:(BOOL)verticalScreen
                           Orientation:(UIInterfaceOrientation)orientation {
    if (verticalScreen) {
        
    }
    else {
        // 横屏条件下 强制竖屏
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientation ;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}

+ (NSString *)dateToStringWithFormat:(NSString *)format date:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *stringDate = [dateFormatter stringFromDate:date]; //当前日期
    return stringDate;
}
+ (NSDate *)stringToDateWithFormat:(NSString *)format dateString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}


//图片缩微图
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image Width:(float)width Height:(float)hight {
    
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratioX = width;
    CGFloat ratioY = hight;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;

    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    CGRect rect = CGRectMake(0.0, 0.0, ratioX, ratioY);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}
@end
