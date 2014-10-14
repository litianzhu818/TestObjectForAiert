

@interface YUVFrame : NSObject
@property (strong, nonatomic) NSData *luma;
@property (strong, nonatomic) NSData *chromaB;
@property (strong, nonatomic) NSData *chromaR;
@property NSInteger width;
@property NSInteger height;
@end
