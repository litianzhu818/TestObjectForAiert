

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "BasicDefine.h"

@protocol StoragePlayBottomViewDelegate <NSObject>

@optional
- (void)clickButtonAtStoragePlayBottomView: (id)sender Index: (NSInteger)aIndex;

@end

@interface StoragePlayBottomView : UIView<StoragePlayBottomViewDelegate> {
    UIView  *currentView;
    NSInteger lastIndex;
    NSInteger imageCount;
    
    NSInteger  _type;
}

@property (nonatomic,retain)UIView *currentView;
@property (nonatomic,assign) id<StoragePlayBottomViewDelegate> delegate;


- (id)initWithType:(CGRect)frame Type:(NSInteger)aType;
- (void)selectAtIndex:(NSInteger)aIndex;

@end
