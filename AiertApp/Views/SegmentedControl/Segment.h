//
//  Segment.h
//  SegmentedControl
//
//  Copyright (c) 2014 Nealon Young. All rights reserved.
//
//  https://github.com/nealyoung/NYSegmentedControl
//

#import <UIKit/UIKit.h>

@class Segment;

@interface Segment : UIView

@property (nonatomic) UILabel *titleLabel;

- (instancetype)initWithTitle:(NSString *)title;

@end
