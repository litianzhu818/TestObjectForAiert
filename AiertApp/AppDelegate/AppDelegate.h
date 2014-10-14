

#import <UIKit/UIKit.h>
#import "AiertDeviceCoreDataStorage.h"
#import "AiertDeviceCoreDataManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,AiertDeviceCoreDataManagerDelegate>
{
    AiertDeviceCoreDataStorage *aiertDeviceCoreDataStorage;
    AiertDeviceCoreDataManager *aiertDeviceCoreDataManager;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly) AiertDeviceCoreDataStorage *aiertDeviceCoreDataStorage;
@property (readonly) AiertDeviceCoreDataManager *aiertDeviceCoreDataManager;

@end
