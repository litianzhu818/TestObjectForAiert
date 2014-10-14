

#import "RootTabBarViewController.h"

#import "BasicDefine.h"
#import "RootTabBar.h"
#import "UIColor+AppTheme.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

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
//MARK:这里需要调整
//???:注意这里的注释
//    [self loadTabBarImage];
//    [self localizedSupport];
//    [self setTabBarText];
    
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.tabBar.frame.size.width,
                                                                      self.tabBar.frame.size.height)];
    backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);
    //backgroundView.backgroundColor = [UIColor AppThemeBarTintColor];
    backgroundView.backgroundColor = [UIColor colorWithRed:124.0/255.0f green:111.0/255.0f blue:176.0/255.0f alpha:1.0];
    
    
    [self.tabBar insertSubview:backgroundView atIndex:(IOS7_OR_LATER) ? 0 : 1];
    [self.tabBar setTintColor:[UIColor whiteColor]];
    self.tabBar.opaque = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    NSArray *itemTitles = @[NSLocalizedString(@"List", @"List"),
                            NSLocalizedString(@"Storage", @"Storage"),
                            NSLocalizedString(@"More", @"More")];
    
    [itemTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[self.tabBar.items objectAtIndex:idx] setTitle:obj];
    }];
}

#pragma mark -
#pragma mark TabBar

- (void)setTabBarText
{
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = [self.tabBar.items objectAtIndex:i];
        
        [item setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor AppThemeSelectedTextColor],
          UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        [item setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor],
          UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        [item setTitlePositionAdjustment:UIOffsetMake(0, -5)];
    }
}

- (void)loadTabBarImage
{
    //Load Image
    NSArray *tabBarSelectedImages = [[NSArray alloc] initWithObjects:
                                     [UIImage imageNamed:@"tabbar_list_selected.png"],
                                     [UIImage imageNamed:@"tabbar_storage_selected.png"],
                                     [UIImage imageNamed:@"tabbar_more_selected.png"],
                                     nil];
    NSArray *tabBarUnselectedImages = [[NSArray alloc] initWithObjects:
                                       [UIImage imageNamed:@"tabbar_list_unselected.png"],
                                       [UIImage imageNamed:@"tabbar_storage_unselected.png"],
                                       [UIImage imageNamed:@"tabbar_more_unselected.png"],
                                       nil];
    for (int i = 0; i < self.tabBar.items.count; i++) {
        UITabBarItem *item = [self.tabBar.items objectAtIndex:i];
        [item setImage:nil];
        [item setFinishedSelectedImage:[tabBarSelectedImages objectAtIndex:i]
           withFinishedUnselectedImage:[tabBarUnselectedImages objectAtIndex:i]];
    }
}

/*
 - (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
 {
 RootTabBar *rootTabBar = (RootTabBar *)self.tabBar;
 [rootTabBar redrawLayer];
 }
 */

#pragma mark -
#pragma mark Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    UIViewController *viewController = [self selectedViewController];
    if ([viewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [viewController supportedInterfaceOrientations];
    }
    else
        return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    UIViewController *viewController = [self selectedViewController];
    if ([viewController respondsToSelector:@selector(shouldAutorotate)])
    {
        return [viewController shouldAutorotate];
    }
    else
        return NO;
}

@end
