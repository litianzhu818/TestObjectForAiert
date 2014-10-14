


#import <UIKit/UIKit.h>
#import "DragButton.h"
#import "UIScrollViewEx.h"
#import "ZMRecorderFileIndex.h"

#import "ZMRecorderFileIndex.h"
#import "Utilities.h"
#import "AppData.h"

@protocol StorageMoreViewDelegate

@optional
-(void)delButtonAtIndexInStorageMoreView:(NSInteger)aIndex;

-(void)doubleClickAtIndexInStorageMoreView:(NSInteger)aIndex;

-(void)singleClickAtIndexInStorageMoreView:(NSInteger)aIndex;

@end

@interface StorageMoreView : UIView <StorageMoreViewDelegate,DragButtonDelegate,UIScrollViewExDelegate> {
    
    NSMutableArray *_dragButtonDataArr;
    BOOL bShowAllDelButton;
    BOOL _bChoiceAllButton;
}

@property(nonatomic,retain)NSMutableArray *dataArr;
@property(strong, nonatomic) UIScrollViewEx *scrollViewEx;
@property(nonatomic,assign) id<StorageMoreViewDelegate> storageMoreViewDelegate;

- (void)reloadData;
- (void)initData;
- (void)showAllDelButtonInStorageMoreView:(BOOL)bShow;
@end