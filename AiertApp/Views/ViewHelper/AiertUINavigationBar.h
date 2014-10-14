//
//  AiertUINavigationBar.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/9.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AiertUINavigationBar : UINavigationBar

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
@property (strong, nonatomic) UIImage *backgroundImage;

#endif

@end
