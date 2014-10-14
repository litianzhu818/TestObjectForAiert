//
//  UINavigationController+Rotation.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation)

-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
