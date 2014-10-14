

#import "RootNavigationController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

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
	// Do any additional setup after loading the view.
    
    //设置背景
    if (IOS7_OR_LATER) {
        //Changed by RealZYC
        [self.navigationBar setBarTintColor:[UIColor AppThemeBarTintColor]];
        //self.navigationController.navigationBar.translucent = NO;
    }
    else{
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_background.png"] forBarMetrics:UIBarMetricsDefault];
        //RealZYC Add 20131111: 去除多余黑线
        self.navigationBar.clipsToBounds = YES;
    }
    
    //设置字体
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, [UIFont fontWithName:@"Helvetica" size:20.0f],UITextAttributeFont,nil]];
    
//    //解决IOS7下遮挡
//    if (IOS7_OR_LATER) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    UIViewController *viewController = [self visibleViewController];
    if ([viewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [viewController supportedInterfaceOrientations];
    }
    else
        return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    UIViewController *viewController = [self visibleViewController];
    if ([viewController respondsToSelector:@selector(shouldAutorotate)])
    {
        return [viewController shouldAutorotate];
    }
    else
        return NO;
}

@end
