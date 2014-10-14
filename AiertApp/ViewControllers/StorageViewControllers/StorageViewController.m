

#import "StorageViewController.h"

@implementation StorageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self localizedSupport];
    
    [self initParameters];
    
    StorageListViewController *viewController = [[StorageListViewController alloc] initWithNibName:nil bundle:nil];
    [viewController.view setBackgroundColor:[UIColor clearColor]];
    viewController.view.frame = self.view.bounds;
    viewController.storageListViewControllerDelegate = self;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.listViewController = viewController;
    [self.view addSubview:viewController.view];
    
    
    [self initDataInStorageViewController];
    _firstLoad = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initParameters
{
    [self initData];
    [self initUI];
}
-(void)initUI
{
    [self.navigationItem setTitle:@"报警"];
    UIImage *image = PNG_NAME(@"btn_big");
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width*0.5) topCapHeight:floorf(image.size.height*0.5)];
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationItem.titleView setTintColor:[UIColor whiteColor]];
}
-(void)initData
{
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.hidesBottomBarWhenPushed = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_firstLoad) {
        _firstLoad = NO;
    }
    else {
        [self reloadDataInStorageViewController];
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"报警", @"Storage");
}

- (void)initDataInStorageViewController {
    self.dataDic = [ZMRecorderFileIndexManage recorderFileIndexs];
    
    [self reSetMyDataArray];
    [self.listViewController initListDataWithArr:_dataArray];
}

- (void)reloadDataInStorageViewController {
    self.dataDic = [ZMRecorderFileIndexManage recorderFileIndexs];
    
    [self reSetMyDataArray];
    [self.listViewController reloadData:_dataArray];
}

- (void)reSetMyDataArray {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSString *aKey in [_dataDic allKeys]) {
        [arr addObject:aKey];
    }
    self.dataArray = arr;
}

- (void)delFileNameAtPath:(NSString *)fileNamePath {
    DLog(@"delFileNameAtPath....%@",fileNamePath);
    [[NSFileManager defaultManager] removeItemAtPath:fileNamePath error:nil];
}

- (void)singleClickAtIndexInStorageListViewController:(id)data {
    [self performSegueWithIdentifier:@"PlayVideoAndImage"
                              sender:data];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.hidesBottomBarWhenPushed = YES;
    if ([segue.identifier isEqualToString:@"PlayVideoAndImage"]) {
        PlayVideoAndImageViewController *viewController = segue.destinationViewController;
        viewController.playVideoAndImageViewControllerDelegate = self;
        [viewController initWithDataArr:sender];
    }
}

#pragma Mark PlayVideoAndImageViewControllerDelegate
- (void)deleteDataAtIndexInPlayVideoAndImageViewController:(NSInteger)aIndex {
    NSLog(@"deleteDataAtIndexInPlayVideoAndImageViewController ...aIndex:%d",aIndex);
    
    if (aIndex >= 0 && aIndex < [_dataArray count]) {

        [_dataDic removeObjectForKey:[_dataArray objectAtIndex:aIndex]];
        
        //begin 要删除实际文件
        
        //删除大图
        NSString *imageName = [NSString stringWithFormat:@"%@.png",
                               [_dataArray objectAtIndex:aIndex]];
        
        NSString *imageFilePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:[NSString stringWithFormat:@"%@",imageName]];
        
        [self delFileNameAtPath:imageFilePath];
        
        //删除缩微图
        NSString *smallImageName = [NSString stringWithFormat:@"%@_small.png",
                                     [_dataArray objectAtIndex:aIndex]];
        
        NSString *smallImageFilePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:[NSString stringWithFormat:@"%@",smallImageName]];
        
        [self delFileNameAtPath:smallImageFilePath];
        //end 要删除实际文件
        
        
        [ZMRecorderFileIndexManage writeRecorderFileIndex:_dataDic];
        
        [self reSetMyDataArray];
        
        [self.listViewController reloadData:_dataArray];
    }
}

@end
