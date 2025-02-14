#import <UIKit/UIKit.h>

@interface TTTAttributedLabel : UILabel
@property (nonatomic, assign) NSTimeInterval lastClickTime;
@end

@interface XYTabBar : UIView
@property (nonatomic, strong) NSArray *subviews;
@property (nonatomic, assign) CGRect bounds;
@end

// ... 其他类声明 ... 