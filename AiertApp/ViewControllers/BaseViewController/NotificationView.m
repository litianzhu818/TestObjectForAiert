//
//  NotificationView.m
//  KISSNAPP
//
//  Created by Peter Lee on 14/6/17.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "NotificationView.h"

static CGRect notificationRect()
{
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, kMPNotificationHeight);
    }
    
    return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, kMPNotificationHeight);
}

#pragma mark NotificationWindow

@interface NotificationWindow : UIWindow

@property (nonatomic, strong) UIView *currentNotification;

@end

@implementation NotificationWindow

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *topHalfBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                            CGRectGetMinY(frame),
                                                                            CGRectGetWidth(frame),
                                                                            0.5 * CGRectGetHeight(frame))];
        /**************************************************************/
        topHalfBlackView.backgroundColor = [UIColor clearColor];
        topHalfBlackView.layer.zPosition = -100;
        topHalfBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:topHalfBlackView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
        
        [self rotateStatusBarWithFrame:frame];
    }
    
    return self;
}

- (void) willRotateScreen:(NSNotification *)notification
{
    CGRect notificationBarFrame = notificationRect();
    
    if (self.hidden)
    {
        [self rotateStatusBarWithFrame:notificationBarFrame];
    }
    else
    {
        [self rotateStatusBarAnimatedWithFrame:notificationBarFrame];
    }
}

- (void) rotateStatusBarAnimatedWithFrame:(CGRect)frame
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self rotateStatusBarWithFrame:frame];
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              self.alpha = 1;
                                          }];
                     }];
}


- (void) rotateStatusBarWithFrame:(CGRect)frame
{
    BOOL isPortrait = (frame.size.width == [UIScreen mainScreen].bounds.size.width);
    
    if (isPortrait)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.width = kMPNotificationIPadWidth;
        }
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)
        {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - kMPNotificationHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(180.0f));
        }
        else
        {
            self.transform = CGAffineTransformIdentity;
        }
    }
    else
    {
        frame.size.height = frame.size.width;
        frame.size.width  = kMPNotificationHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.height = kMPNotificationIPadWidth;
        }
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft)
        {
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width;
            self.transform = CGAffineTransformMakeRotation(RADIANS(90.0f));
        }
        else
        {
            self.transform = CGAffineTransformMakeRotation(RADIANS(-90.0f));
        }
    }
    
    self.frame = frame;
    CGPoint center = self.center;
    if (isPortrait)
    {
        center.x = CGRectGetMidX([UIScreen mainScreen].bounds);
    }
    else
    {
        center.y = CGRectGetMidY([UIScreen mainScreen].bounds);
    }
    self.center = center;
}

@end
/***************************************************************/
static NotificationWindow * __notificationWindow = nil;
static CGFloat const __imagePadding = 8.0f;
/***************************************************************/

@interface NotificationView ()

@property (nonatomic, strong) GradientView * contentView;

-(void) showTextNotification;
-(UIImage*) screenImageWithRect:(CGRect)rect;

@end


@implementation NotificationView
Single_implementation(NotificationView);

- (instancetype)init
{
    if (__notificationWindow == nil)
    {
        __notificationWindow = [[NotificationWindow alloc] initWithFrame:notificationRect()];
        __notificationWindow.hidden = NO;
    }
    //NSLog(@"%f##%f",__notificationWindow.bounds.size.width,__notificationWindow.bounds.size.height);
    NotificationView *view = [[NotificationView alloc] initWithFrame:__notificationWindow.bounds];
    return view;
}

- (void) dealloc
{
    _delegate = nil;
}

- (void)showViewWithText:(NSString*)text
                  detail:(NSString*)detail
                   image:(UIImage*)image
{

    self.textLabel.text = text;
    self.detailTextLabel.text = detail;
    self.imageView.image = image;
    
    [self showTextNotification];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat notificationWidth = notificationRect().size.width;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _contentView = [[GradientView alloc] initWithFrame:self.bounds];
        _contentView.colors = @[(id)[[UIColor colorWithWhite:0.99f alpha:1.0f] CGColor],
                                (id)[[UIColor colorWithWhite:0.9f  alpha:1.0f] CGColor]];
        //**************************************************************这里设置视图角度
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //_contentView.layer.cornerRadius = 8.0f;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        //**************************************************************这里设置图片角度
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 4.0f;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        //****************************************************************************
        UIFont *textFont = [UIFont boldSystemFontOfSize:14.0f];
        CGRect textFrame = CGRectMake(__imagePadding + CGRectGetMaxX(_imageView.frame),
                                      2,
                                      notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                      textFont.lineHeight);
        _textLabel = [[UILabel alloc] initWithFrame:textFrame];
        _textLabel.font = textFont;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_textLabel];
        
        UIFont *detailFont = [UIFont systemFontOfSize:13.0f];
        CGRect detailFrame = CGRectMake(CGRectGetMinX(textFrame),
                                        CGRectGetMaxY(textFrame),
                                        notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                        detailFont.lineHeight);
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:detailFrame];
        _detailTextLabel.font = detailFont;
        _detailTextLabel.numberOfLines = 1;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_detailTextLabel];
        //Button
        _accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(notificationWidth - 64, 6, 60, 28)];
        [_accessoryButton setTitle:@"Delete" forState:UIControlStateNormal];
        _accessoryButton.backgroundColor = [UIColor redColor];
        [_accessoryButton addTarget:self action:@selector(clikedOnButton) forControlEvents:UIControlEventTouchDown];
        [_contentView addSubview:_accessoryButton];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                      CGRectGetHeight(frame) - 1.0f,
                                                                      CGRectGetWidth(frame),
                                                                      1.0f)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        
        [_contentView addSubview:bottomLine];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.accessoryButton.frame = CGRectMake(notificationRect().size.width - 64, 6, 60, 28);
}

-(void)clikedOnButton{
    [self showTextNotification];
    if ([_delegate respondsToSelector:@selector(deleteNotificationView)])
    {
        [_delegate deleteNotificationView];
    }
}

- (void)dissmissNotificationView
{
    if (!_isLoading) {
        return;
    }
    //消失视图
    [self showTextNotification];
}

- (void) showTextNotification
{
    UIView *viewToRotateOut = nil;
    UIImage *screenshot = [self screenImageWithRect:__notificationWindow.frame];
    
    if (__notificationWindow.currentNotification){
        viewToRotateOut = __notificationWindow.currentNotification;
    }else{
        viewToRotateOut = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateOut).image = screenshot;
        [__notificationWindow addSubview:viewToRotateOut];
        __notificationWindow.hidden = NO;
    }
    
    UIView *viewToRotateIn = nil;
    if (!_isLoading) {
        viewToRotateIn = [self copy];
    }else{
        viewToRotateIn = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateIn).image = screenshot;
    }
    
    viewToRotateIn.layer.anchorPointZ = 11.547f;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 2;
    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(RADIANS(-120), 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0 / 200.0;
    
    viewToRotateOut.layer.anchorPointZ = 11.547f;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 2;
    
    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(RADIANS(120), 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0 / 200.0;
    
    [__notificationWindow addSubview:viewToRotateIn];
    __notificationWindow.backgroundColor = [UIColor blackColor];
    
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    if ([viewToRotateIn isKindOfClass:[NotificationView class]] ){
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        bgImage.image = screenshot;
        [viewToRotateIn addSubview:bgImage];
        [viewToRotateIn sendSubviewToBack:bgImage];
        __notificationWindow.currentNotification = viewToRotateIn;
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {//将正常的视图隐藏，显示提示界面
                         [viewToRotateOut removeFromSuperview];
                         if ([viewToRotateIn isKindOfClass:[NotificationView class]]){
                             NotificationView *notification = (NotificationView*)viewToRotateIn;
                             __notificationWindow.currentNotification = notification;
                             _isLoading = YES;
                         }else{//将提示的视图移除，显示正常界面
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                             _isLoading = NO;
                         }
                         __notificationWindow.backgroundColor = [UIColor clearColor];
                     }];
}

- (UIImage *) screenImageWithRect:(CGRect)rect
{
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale
                      , rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                      scale:croppedScreenshot.scale
                                orientation:imageOrientation];
}


@end
