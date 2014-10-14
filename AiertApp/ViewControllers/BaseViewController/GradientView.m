
#import "GradientView.h"



#pragma mark -
#pragma mark Implementation

@implementation GradientView

@dynamic gradientLayer;
@dynamic colors, locations, startPoint, endPoint, type;


// Make the view's layer a CAGradientLayer instance
+ (Class)layerClass 
{
    return [CAGradientLayer class];
}



// Convenience property access to the layer help omit typecasts
- (CAGradientLayer *)gradientLayer 
{
    return (CAGradientLayer *)self.layer;
}



#pragma mark -
#pragma mark Gradient-related properties

- (NSArray *)colors 
{
    NSArray *cgColors = self.gradientLayer.colors;
    if (cgColors == nil) {
        return nil;
    }
    
    // Convert CGColorRefs to UIColor objects
    NSMutableArray *uiColors = [NSMutableArray arrayWithCapacity:[cgColors count]];
    for (id cgColor in cgColors) {
        [uiColors addObject:[UIColor colorWithCGColor:(CGColorRef)cgColor]];
    }
    return [NSArray arrayWithArray:uiColors];
}


// The colors property accepts an array of CGColorRefs or UIColor objects (or mixes between the two).
// UIColors are converted to CGColor before forwarding the values to the layer.
- (void)setColors:(NSArray *)newColors 
{
    NSMutableArray *newCGColors = nil;

    if (newColors != nil) {
        newCGColors = [NSMutableArray arrayWithCapacity:[newColors count]];
        for (id color in newColors) {
            // If the array contains a UIColor, convert it to CGColor.
            // Leave all other types untouched.
            if ([color isKindOfClass:[UIColor class]]) {
                [newCGColors addObject:(id)[color CGColor]];
            } else {
                [newCGColors addObject:color];
            }
        }
    }
    
    self.gradientLayer.colors = newCGColors;
}


- (NSArray *)locations 
{
    return self.gradientLayer.locations;
}

- (void)setLocations:(NSArray *)newLocations 
{
    self.gradientLayer.locations = newLocations;
}

- (CGPoint)startPoint 
{
    return self.gradientLayer.startPoint;
}

- (void)setStartPoint:(CGPoint)newStartPoint 
{
    self.gradientLayer.startPoint = newStartPoint;
}

- (CGPoint)endPoint 
{
    return self.gradientLayer.endPoint;
}

- (void)setEndPoint:(CGPoint)newEndPoint 
{
    self.gradientLayer.endPoint = newEndPoint;
}

- (NSString *)type 
{
    return self.gradientLayer.type;
}

- (void) setType:(NSString *)newType 
{
    self.gradientLayer.type = newType;
}

@end