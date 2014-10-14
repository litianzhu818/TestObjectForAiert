
#import <Foundation/Foundation.h>

@interface MessageInfo : NSObject

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *fromID;
@property (copy, nonatomic) NSString *toID;
@property (copy, nonatomic) NSDictionary *messageContent;
@property (copy, nonatomic) NSString *messageType;
@property (copy, nonatomic) NSString *ifRead;
@property (copy, nonatomic) NSString *createTime;
@property (copy, nonatomic) NSString *devName;

@end
