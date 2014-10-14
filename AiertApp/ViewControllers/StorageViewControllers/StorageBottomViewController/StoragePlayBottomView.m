
#import "StoragePlayBottomView.h"

#define wSpace                                              0
#define kTag                                                30001
#define kStoragePlay_Bottom_Height                          49

@interface  StoragePlayBottomView (private)
-(void)buttonAction:(id)sender;
-(void)resetButtonImage;
-(void)didSelectAtIndex:(id)sender Index:(NSInteger)aIndex;
@end

@implementation StoragePlayBottomView
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
        
        UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kStoragePlay_Bottom_Height)];
        backImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
        backImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PBottom_bottomBK" ofType:@"png"]];
        [self addSubview:backImage];
        
        currentView = nil;
        lastIndex = -1;
        _type = aType;
        int x = 0;
        int y = 0;
        UIImage *image = [UIImage imageNamed:@"PBottom_100.png"];
        CGImageRef cgImage = image.CGImage;
        int imageWidth = CGImageGetWidth(cgImage)/2;
        int imageHeight = kStoragePlay_Bottom_Height;
        
        if (StoragePlayBottomTypeImage == _type) {
            imageCount = 1;
            imageWidth = 80.0;
            x = (self.bounds.size.width - imageWidth) / 2;
        }
        else {
            imageCount = 4;
            imageWidth = self.bounds.size.width / imageCount;
        }

        for(NSInteger i = 0; i < imageCount; i++){
            
            NSString *imgName = [NSString stringWithFormat:@"%@Bottom_10%d.png",_type == StoragePlayBottomTypeImage ? @"P" : @"V",i];
            
            NSString *sel_imgName = [NSString stringWithFormat:@"%@Bottom_10%d-sel.png",_type == StoragePlayBottomTypeImage ? @"P" : @"V",i];
            
            image = [UIImage imageNamed:imgName];
            UIImage *sel_image = [UIImage imageNamed:sel_imgName];
            UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(x, y, imageWidth, imageHeight)];
            [button setTag: kTag+i];
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
        NSString *last_img = [NSString stringWithFormat:@"%@Bottom_10%d",_type == StoragePlayBottomTypeImage ? @"P" : @"V",lastIndex];
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

-(void)didSelectAtIndex:(id)sender Index:(NSInteger)aIndex {
    if(delegate &&[(id)delegate respondsToSelector: @selector(clickButtonAtStoragePlayBottomView:Index:)]) {
        [delegate clickButtonAtStoragePlayBottomView:sender Index:aIndex];
    }
    lastIndex = aIndex;
}

- (void)selectAtIndex:(NSInteger)aIndex {
    
    [self resetButtonImage];
    /*UIButton *btn = (UIButton*)[self viewWithTag:aIndex + kTag];

    NSString *sel_img = [NSString stringWithFormat:@"%@Bottom_10%d-sel.png",_type == StoragePlayBottomType_Image ? @"P" : @"V",aIndex];

    [btn setImage:[UIImage imageNamed:sel_img] forState:UIControlStateNormal];*/
    lastIndex = aIndex;
}

@end
