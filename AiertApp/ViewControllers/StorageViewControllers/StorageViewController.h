

#import <UIKit/UIKit.h>
#import "StorageListViewController.h"
#import "PlayVideoAndImageViewController.h"
#import "ZMRecorderFileIndexManage.h"

@interface StorageViewController : BaseViewController<StorageListViewControllerDelegate,PlayVideoAndImageViewControllerDelegate> {
    
    BOOL _firstLoad;
}

@property(strong,nonatomic) StorageListViewController *listViewController;
@property(strong,nonatomic) NSMutableDictionary *dataDic;
@property(strong,nonatomic) NSMutableArray *dataArray;

@end
