
#import "ZMRecorderFileIndexManage.h"

@implementation ZMRecorderFileIndexManage

+ (ZMRecorderFileIndexManage *)sharedManage
{
    static  ZMRecorderFileIndexManage *sharedInstance = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

+ (id)recorderFileIndexs {
    
    DLog(@"recordList : ----------------- ------ ---------- ----------  ------ > %@",
         [Utilities persistedInfoFromFolderPath:[[AppData lastLoginUser] userId]
                                       fileName:@"RecordListIndex"
                                            key:@"RecordListIndex"]);
    return [Utilities persistedInfoFromFolderPath:[[AppData lastLoginUser] userId]
                                         fileName:@"RecordListIndex"
                                              key:@"RecordListIndex"];
}
+ (BOOL)addRecorderFileIndex:(id)recorderFileIndex {
    
    //从文件中读入数据
    NSMutableDictionary *dic = [ZMRecorderFileIndexManage recorderFileIndexs];
    if (nil == dic) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        dic = tempDic;
    }
    
    //增加内存中字典的数据
    ZMRecorderFileIndex *indexData = (ZMRecorderFileIndex *)recorderFileIndex;
    [dic setObject:recorderFileIndex forKey:indexData.recorderId];
    
    //写入文件
    [ZMRecorderFileIndexManage writeRecorderFileIndex:dic];
    
    return YES;
}
+ (BOOL)removeRecorderFileIndex:(id)recorderId {
    
    //从文件中读入数据
    NSMutableDictionary *dic = [ZMRecorderFileIndexManage recorderFileIndexs];
    
    if (dic) {
        //内存中字典中删除数据
        ZMRecorderFileIndex *indexData = (ZMRecorderFileIndex *)recorderId;
        [dic removeObjectForKey:indexData.recorderId];
        
        //写入文件
        [ZMRecorderFileIndexManage writeRecorderFileIndex:dic];
        
        return YES;
    }
    return NO;
}


+ (BOOL)writeRecorderFileIndex:(id)dic {
    //写入文件
    return [Utilities persistentInfo:dic
                          folderPath:[[AppData lastLoginUser] userId]
                            fileName:@"RecordListIndex"
                                 key:@"RecordListIndex"];
}

+ (BOOL)saveScreenShotImage:(id)image deviceId:(NSString *)devId channel:(NSInteger)channel
{
    ZMRecorderFileIndex *item = [[ZMRecorderFileIndex alloc] initWithRecordDeviceId:devId
                                                                             channel:channel
                                                                           startTime:
                                  [Utilities dateToStringWithFormat:@"yyyyMMddhhmmss" date:[NSDate date]]
                                                                       fileExtension:@"png"
                                                                                type:0];
    
    
    [ZMRecorderFileIndexManage addRecorderFileIndex:item];
    
    
    //begin image
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *sImageName = [NSString stringWithFormat:@"%@.png",item.recorderId];
    
    NSString *imageFilePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:[NSString stringWithFormat:@"%@",sImageName]];
    
    [imageData writeToFile:imageFilePath atomically:NO];
    DLog(@"save Png.. %@",imageFilePath);
    //end image
    
    //begin small_image
    UIImage *smallImage = [Utilities generatePhotoThumbnail:image Width:75.0 Height:60.0];
    
    NSString *smallImageName = [NSString stringWithFormat:@"%@_small.png",item.recorderId];
    
    NSData *smallImageData = UIImagePNGRepresentation(smallImage);
    
    NSString *smallImageFilePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:[NSString stringWithFormat:@"%@",smallImageName]];
    
    [smallImageData writeToFile:smallImageFilePath atomically:NO];
    DLog(@"save small_png.. %@",smallImageFilePath);

    return YES;
}

@end
