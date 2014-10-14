

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "BasicDefine.h"
#import "StorageMoreView.h"
#import "PlayVideoAndImageViewController.h"
#import "ZMRecorderFileIndexManage.h"

@protocol StorageListViewControllerDelegate <NSObject>

@optional
- (void)singleClickAtIndexInStorageListViewController:(id)data;

@end

@interface StorageListViewController : BaseViewController<StorageMoreViewDelegate,StorageListViewControllerDelegate> {
    
}

@property(strong,nonatomic) StorageMoreView *moreView;
@property(weak, nonatomic) id<StorageListViewControllerDelegate> storageListViewControllerDelegate;

- (void)initListDataWithArr:(NSMutableArray *)arr;

- (void)reloadData:(NSMutableArray *)arr;



/*
- (IBAction)testButton1_TouchUpInside:(id)sender;
- (IBAction)testButton2_TouchUpInside:(id)sender;
- (IBAction)testButton3_TouchUpInside:(id)sender;
- (IBAction)testButton4_TouchUpInside:(id)sender;
 
 */

@end
