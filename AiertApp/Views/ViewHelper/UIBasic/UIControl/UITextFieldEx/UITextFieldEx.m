

#import "UITextFieldEx.h"

#define UITextFieldExDefaultPadding 10;

@implementation UITextFieldEx

@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize placeHolderColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        paddingLeft = UITextFieldExDefaultPadding;
        paddingRight = UITextFieldExDefaultPadding;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        paddingLeft = UITextFieldExDefaultPadding;
        paddingRight = UITextFieldExDefaultPadding;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        paddingLeft = UITextFieldExDefaultPadding;
        paddingRight = UITextFieldExDefaultPadding;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect bounds_super = [super textRectForBounds:bounds];
    return CGRectMake(bounds_super.origin.x + paddingLeft, bounds_super.origin.y,
                      bounds_super.size.width - paddingLeft - paddingRight, bounds_super.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect bounds_super = [super editingRectForBounds:bounds];
    return CGRectMake(bounds_super.origin.x + paddingLeft, bounds_super.origin.y,
                      bounds_super.size.width - paddingLeft - paddingRight, bounds_super.size.height);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (placeHolderColor == nil) {
        [super drawPlaceholderInRect:rect];
    }
    else
    {
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        [placeHolderColor setFill];
        CGSize size = [self.placeholder sizeWithFont:self.font
                                   constrainedToSize:rect.size
                                       lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat y = (rect.size.height - size.height) / 2;
        CGRect rectDraw = CGRectMake(rect.origin.x, rect.origin.y + y, rect.size.width, rect.size.height - y);
        [[self placeholder] drawInRect:rectDraw withFont:self.font];
    }
}

@end
