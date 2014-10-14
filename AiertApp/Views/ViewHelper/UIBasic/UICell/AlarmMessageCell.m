

#import "AlarmMessageCell.h"

#import "UIColor+AppTheme.h"

@implementation AlarmMessageCell
{
    BOOL _ifRead;
    CALayer *readLayer;
}

@synthesize ifRead;

- (BOOL)ifRead
{
    return _ifRead;
}

-(void)setIfRead:(BOOL)aIfRead
{
    
    if (readLayer) {
        if (aIfRead) {
            [readLayer removeFromSuperlayer];
            readLayer = nil;
            _messageLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        }
        else{
            return;
        }
    }
    else{
        if (!aIfRead) {
            readLayer = [CALayer layer];
            readLayer.frame = CGRectMake(5, 14, 6, 6);
            readLayer.contentsScale = [UIScreen mainScreen].scale;
            readLayer.cornerRadius = 3;
            readLayer.backgroundColor = [UIColor AppThemeBarTintColor].CGColor;
            readLayer.borderColor = readLayer.backgroundColor;
            readLayer.borderWidth = 0.1f;
            [self.backView.layer insertSublayer:readLayer atIndex:1];
            _messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        }
        else{
            [readLayer removeFromSuperlayer];
            readLayer = nil;
            _messageLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        }
    }
    _ifRead = aIfRead;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
