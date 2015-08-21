@interface FLYUtilities : NSObject

+ (CGFloat) FLYMainScreenScale;
+ (CGFloat)hairlineHeight;
+ (void)printAutolayoutTrace;
+ (BOOL)isInvalidUser;
+ (NSString *)getCountryDialCode;
+ (void)gotoReviews;
+ (NSString *)appVersion;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end