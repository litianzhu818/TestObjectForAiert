

#import "UIColor+AppTheme.h"

@implementation UIColor (AppTheme)

//BarTintColor for app theme
//RealZYC Add
+ (UIColor *)AppThemeBarTintColor
{
    //(0,176,237) -> (0,123,255)
    int r=48,g=48,b=48;
    //int r=120,g=120,b=120;
    //参考http://news.ipadown.com/30103
    return [UIColor colorWithRed:r/255.0f
                                green:g/255.0f
                                blue:b/255.0f alpha:1];
}

//BarBackgroundColor for app theme
//RealZYC Add
+ (UIColor *) AppThemeSelectedTextColor
{
    int r=75,g=189,b=231;
    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f alpha:1];
}

+ (UIColor *)AppThemeTableViewBackgroundColor
{
    int r=234,g=234,b=234;
    return [UIColor colorWithRed:r/255.0f
                           green:g/255.0f
                            blue:b/255.0f alpha:1];
}

+ (UIColor *)AppThemePlaceHolderColor
{
    return [UIColor colorWithRed:75/255.0f
                           green:189/255.0f
                            blue:231/255.0f alpha:0.5f];
}

@end
