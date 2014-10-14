

#import "TermOfServiceViewController.h"
#include "BasicDefine.h"
#import "UIColor+AppTheme.h"

#import "UIBarButtonItem+AppTheme.h"

@interface TermOfServiceViewController ()

@end

@implementation TermOfServiceViewController

@synthesize mainScrollView;
@synthesize mainView;

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
    // Do any additional setup after loading the view from its nib.
    [self localizationSupport];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createBackBarButtonItemWithTarget:self action:@selector(backBarItemButton_Click:)];
    
    // Do any additional setup after loading the view.
    
    if (IOS7_OR_LATER) {
        //Changed by RealZYC
        [self.navigationController.navigationBar setBarTintColor:[UIColor AppThemeBarTintColor]];
        //self.navigationController.navigationBar.translucent = NO;
    }
    else{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"topbg-ios"] forBarMetrics:UIBarMetricsDefault];
        //RealZYC Add 20131111: 去除多余黑线
        self.navigationController.navigationBar.clipsToBounds = YES;
    }
    
    //RealZYC Add 20131105, 解决ios7下view被导航栏遮挡
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    //Scorll View
    mainScrollView.directionalLockEnabled = YES; //只能一个方向滑动
    mainScrollView.pagingEnabled = NO; //是否翻页
    //mainScrollView.backgroundColor = [UIColor blackColor];
    mainScrollView.showsVerticalScrollIndicator =YES; //垂直方向的滚动指示
    mainScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;//滚动指示的风格
    mainScrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
    //scollViewMain.delegate = self;
    [self setMainScorllView];

    
}

- (void)backBarItemButton_Click:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//RealZYC
- (void) localizationSupport
{
    self.title =NSLocalizedString(@"Terms of Service", @"");
}

//Set Main view hight
- (void) setMainScorllView
{
    CGRect newframe = mainView.frame;
    [mainScrollView setContentSize:newframe.size];
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
