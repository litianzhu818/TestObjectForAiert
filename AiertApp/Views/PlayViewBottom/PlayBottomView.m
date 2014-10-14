
#import "PlayBottomView.h"

#define wSpace                                              0
#define kTag                                                50001
#define kPlay_Bottom_Height                                 49

@interface PlayBottomView (private)
-(void)buttonAction:(id)sender;
-(void)resetButtonImage;
-(void)didSelectAtIndex:(id)sender Index:(NSInteger)aIndex;
@end

@implementation PlayBottomView
@synthesize currentView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithType:(CGRect)frame Type:(NSInteger)aType {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kPlay_Bottom_Height)];
        backImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
        backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PBottom_bottomBK" ofType:@"png"]];
        [self addSubview:backImage];
        
        
        currentView = nil;
        lastIndex = -1;
        _type = aType;
        int x = 0;
        int y = -8.0;
        UIImage *image = [UIImage imageNamed:@"live_100.png"];
        CGImageRef cgImage = image.CGImage;
        int imageWidth = CGImageGetWidth(cgImage)/2;
        int imageHeight = kPlay_Bottom_Height;
        
   
        imageCount = 5;
        imageWidth = self.bounds.size.width / imageCount;
        
        self.qualityIndex = 0;
        
        for(NSInteger i = 0; i < imageCount; i++) {
            
            NSString *imgName = [NSString stringWithFormat:@"live_10%d.png",i];
            
            NSString *sel_imgName = [NSString stringWithFormat:@"live_10%d_sel.png",i];
            if (PlayBottomTypeQuality == i) {
                imgName = [NSString stringWithFormat:@"live_10%d_%d.png",i,_qualityIndex];
                sel_imgName = [NSString stringWithFormat:@"live_10%d_%d_sel.png",i,_qualityIndex];
            }
            
            image = [UIImage imageNamed:imgName];
            UIImage *sel_image = [UIImage imageNamed:sel_imgName];
            //UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(x, y, imageWidth, imageHeight)];
            UIButtonWithTouchDown *button = [[UIButtonWithTouchDown alloc] initWithFrame: CGRectMake(x, y, imageWidth, imageHeight)];
            [button setTag: kTag+i];
            button.buttonWithTouchDownDelegate = self;
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
            [button setImage: image forState: UIControlStateNormal];
            [button setImage: sel_image forState: UIControlStateHighlighted];
            [button addTarget: self action: @selector(buttonAction:) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview: button];
            
            x += imageWidth;
        }
    }
    return self;
}

//上一个被点击的索引按钮的背景图片换掉
-(void)resetButtonImage {
	if (lastIndex < 0) {
		return;
	}else {
		UIButton *butt=(UIButton *)[self viewWithTag:kTag+lastIndex];
        NSString *last_img = [NSString stringWithFormat:@"live_10%d.png",lastIndex];
        if (PlayBottomTypeQuality == lastIndex) {
            last_img = [NSString stringWithFormat:@"live_10%d_%d.png",lastIndex,_qualityIndex];
        }
		[butt setImage:[UIImage imageNamed:last_img] forState:UIControlStateNormal];
	}
}

-(void)buttonAction:(id)sender {
    [self resetButtonImage];
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = [btn tag];
   // NSString *sel_img = [NSString stringWithFormat:@"%@Bottom_10%d-sel",_type == StoragePlayBottomType_Image ? @"P" : @"V",tag-kTag];
   // [btn setImage:[UIImage imageNamed:sel_img] forState:UIControlStateNormal];
    if(currentView != nil)
        [currentView removeFromSuperview];
    
    [self didSelectAtIndex:sender Index:tag-kTag];
}



- (void)selectAtIndexWithOpenStatus:(NSInteger)aIndex OpenStatus:(BOOL)open {
    
    //[self resetButtonImage];
    UIButton *btn = (UIButton*)[self viewWithTag:aIndex + kTag];
    switch (aIndex) {
        case PlayBottomTypeSound:
        case PlayBottomTypeTalk: {
            NSString *img = [NSString stringWithFormat:@"live_10%d.png",aIndex];
            
            NSString *hightImg = [NSString stringWithFormat:@"live_10%d_sel.png",aIndex];
            if (!open) {
                img = [NSString stringWithFormat:@"live_10%d_close.png",aIndex];
                
                hightImg = [NSString stringWithFormat:@"live_10%d_close_sel.png",aIndex];
            }
            [btn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
            
            [btn setImage:[UIImage imageNamed:hightImg] forState:UIControlStateHighlighted];
        }
            return;
            break;
            
        default:
            break;
    }
    lastIndex = aIndex;
}

- (void)selectAtQualityIndexWithSubIndex:(NSInteger)aSubIndex {
    
    UIButton *btn = (UIButton*)[self viewWithTag:PlayBottomTypeQuality + kTag];
    
    NSString *img = [NSString stringWithFormat:@"live_10%d_%d.png",PlayBottomTypeQuality,aSubIndex];
    
    NSString *hightImg = [NSString stringWithFormat:@"live_10%d_%d_sel.png",PlayBottomTypeQuality,aSubIndex];

    [btn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:hightImg] forState:UIControlStateHighlighted];
    
    lastIndex = PlayBottomTypeQuality;
}

#pragma Mark UIButtonWithTouchDownDelegate
- (void)didLongPressBeganInUIButtonWithTouchDown:(id)aData Tag:(NSInteger)aTag {
    if (aTag == kTag + PlayBottomTypeTalk) {
        if(delegate &&[(id)delegate respondsToSelector: @selector(didLongPressBeganInPlayBottomView:Tag:)]) {
            [delegate didLongPressBeganInPlayBottomView:aData Tag:aTag];
        }
    }
}

- (void)didLongPressEndInUIButtonWithTouchDown:(id)aData Tag:(NSInteger)aTag {
    if (aTag == kTag + PlayBottomTypeTalk) {
        if(delegate &&[(id)delegate respondsToSelector: @selector(didLongPressEndInPlayBottomView:Tag:)]) {
            [delegate didLongPressEndInPlayBottomView:aData Tag:aTag];
        }
    }
}

#pragma Mark PlayBottomViewDelegate
-(void)didSelectAtIndex:(id)sender Index:(NSInteger)aIndex {
    if(delegate &&[(id)delegate respondsToSelector: @selector(clickButtonAtPlayBottomView:Index:)]) {
        [delegate clickButtonAtPlayBottomView:sender Index:aIndex];
    }
    lastIndex = aIndex;
}




@end
