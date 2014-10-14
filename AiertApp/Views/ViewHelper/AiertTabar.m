//
//  AiertTabar.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/12.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertTabar.h"

@implementation AiertTabar

-(void)setImage:(UIImage *)image
{
    self.image = [image copy];
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
