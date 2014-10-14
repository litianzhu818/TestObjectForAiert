

#import "DeviceListCell.h"

#import "UIColor+AppTheme.h"

@interface DeviceListCell ()
@property (strong, nonatomic) UIView *channelHoldView;
@property (nonatomic) NSInteger channelCount;
@end

@implementation DeviceListCell

+ (DeviceListCell *)cellWithIdentifier:(NSString *)identifier
                                 frame:(CGRect)frame
                          channelCount:(NSInteger)channelCount
{
    
    DLog(@"channel count : %d",channelCount);
    NSAssert(channelCount == 1 ||
             channelCount == 4 ||
             channelCount == 8 ||
             channelCount == 16 ||
             channelCount == 32,
             @"Invalid Channel Count !");
    
    DeviceListCell *cell = [[DeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:identifier];

    
    cell.channelCount = channelCount;
    
    [cell setCellFrame:frame];
    
    cell.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    
    return cell;
}

- (void)setCellFrame:(CGRect)frame
{
    
    DLog(@"%@ called !  channel count : %d",NSStringFromSelector(_cmd),_channelCount);
    [super setFrame:frame];
    
    // set titleLabel
    
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0f,
                                                                    7.0f,
                                                                    frame.size.width-35.0f*2,
                                                                    21.0f)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_titleLabel];
        
        
        // set channelHold view
        self.channelHoldView = [[UIView alloc] initWithFrame:CGRectMake(35.0f,
                                                                        30.0f,
                                                                        frame.size.width-35.0f*2,
                                                                        (frame.size.width-35.0f*2)*70.0f/125.0f)];
        
        [self addSubview:_channelHoldView];
        
        switch (_channelCount) {
            case 1:
            {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                       0.0f,
                                                                                       _channelHoldView.frame.size.width,
                                                                                       _channelHoldView.frame.size.height)];
                imageView.layer.borderWidth = 1;
                imageView.layer.borderColor = [UIColor colorWithRed:188/255.0f
                                                              green:188/255.0f
                                                               blue:188/255.0f
                                                              alpha:188/255.0f].CGColor;
                imageView.image = [UIImage imageNamed:@"list_ipc_offline.png"];
                
                [self.channelHoldView addSubview:imageView];
            }
                break;
            case 4:
            {
                const CGFloat imageWidth = self.channelHoldView.frame.size.width*0.5f-0.5f;
                const CGFloat imageheight = self.channelHoldView.frame.size.height*0.5f-0.5f;
                
                CGPoint startPos[4] = {
                    CGPointMake(0.0f, 0.0f),
                    CGPointMake(imageWidth+1.0f, 0.0f),
                    CGPointMake(0.0f, imageheight+1.0f),
                    CGPointMake(imageWidth+1.0f, imageheight+1.0f)
                };
                
                for (int i=0; i<4; ++i) {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(startPos[i].x,
                                                                                           startPos[i].y,
                                                                                           imageWidth,
                                                                                           imageheight)];
                    imageView.layer.borderWidth = 0.5f;
                    imageView.layer.borderColor = [UIColor colorWithRed:188/255.0f
                                                                  green:188/255.0f
                                                                   blue:188/255.0f
                                                                  alpha:188/255.0f].CGColor;
                    imageView.image = [UIImage imageNamed:@"list_ipc_offline.png"];
                    
                    [self.channelHoldView addSubview:imageView];
                }
                
                
            }
                break;
        }

        
    }
    
    
}

@end
