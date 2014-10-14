

#import "SearchDeviceInLanCell.h"

#import "UIColor+AppTheme.h"

@implementation SearchDeviceInLanCell

@synthesize titleLabel;
@synthesize mainImageView;

+ (SearchDeviceInLanCell *)cellFromXib
{
    SearchDeviceInLanCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"SearchDeviceInLanCell" owner:self options:nil]objectAtIndex:0];
    
    if (cell) {
        cell.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    }
    
    return cell;
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
