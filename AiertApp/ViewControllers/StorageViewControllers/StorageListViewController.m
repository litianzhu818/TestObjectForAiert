

#import "StorageListViewController.h"

#import "ZMRecorderFileIndex.h"
#import "Utilities.h"
#import "AppData.h"

@interface StorageListViewController ()

@end

@implementation StorageListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    StorageMoreView *mView = [[StorageMoreView alloc] initWithFrame:self.view.bounds];
    [mView setBackgroundColor:[UIColor clearColor]];
    self.moreView = mView;
    mView.storageMoreViewDelegate = self;
    mView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)initListDataWithArr:(NSMutableArray *)arr {
    self.moreView.dataArr = arr;
    [self.moreView initData];
}

- (void)reloadData:(NSMutableArray *)arr {
    self.moreView.dataArr = arr;
    [self.moreView reloadData];
}


#pragma mark - StorageMoreViewDelegate
- (void)delButtonAtIndexInStorageMoreView:(NSInteger)aIndex {
    NSLog(@"---- delButtonAtIndexInStorageMoreView  .index:%d",aIndex);
}

- (void)doubleClickAtIndexInStorageMoreView:(NSInteger)aIndex {
    NSLog(@"---- doubleClickAtIndexInStorageMoreView  .index:%d",aIndex);
}

- (void)singleClickAtIndexInStorageMoreView:(NSInteger)aIndex {
    
    if (aIndex >= 0 && aIndex < [_moreView.dataArr count]) {
        
        NSDictionary *dic = [ZMRecorderFileIndexManage recorderFileIndexs];
        /*
         第一个: index
         第二个: value  也是ZMRecorderFileIndex数据
         */
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[NSString stringWithFormat:@"%d",aIndex]];
        [arr addObject:[dic objectForKey:[_moreView.dataArr objectAtIndex:aIndex]]];  //value ,ZMRecorderFileIndex数据
        
        if(_storageListViewControllerDelegate && [(id)_storageListViewControllerDelegate respondsToSelector:@selector(singleClickAtIndexInStorageListViewController:)])
            [_storageListViewControllerDelegate singleClickAtIndexInStorageListViewController:arr];
        
    }
}


@end
