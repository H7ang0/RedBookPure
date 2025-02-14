#import <UIKit/UIKit.h>

@interface AlertWindow : UIWindow

@end

@interface CustomToastView : UIView

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) AlertWindow *alertWindow;
@property (nonatomic, copy) void (^confirmAction)(void);

// 普通提示
+ (void)showToast:(NSString *)message;

// 带确认按钮的提示
+ (void)showConfirmToast:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmAction:(void(^)(void))action;

@end 