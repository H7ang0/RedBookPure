#import "AlertManager.h"

@implementation AlertWindow

- (instancetype)init {
    self = [super init];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

@implementation CustomToastView

+ (void)showToast:(NSString *)message {
    if (!message) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CustomToastView *toast = [[CustomToastView alloc] initWithMessage:message];
        [toast show];
    });
}

+ (void)showConfirmToast:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmAction:(void(^)(void))action {
    if (!message) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CustomToastView *toast = [[CustomToastView alloc] initWithMessage:message isConfirm:YES confirmTitle:confirmTitle];
        toast.confirmAction = action;
        [toast show];
    });
}

- (instancetype)initWithMessage:(NSString *)message {
    return [self initWithMessage:message isConfirm:NO confirmTitle:nil];
}

- (instancetype)initWithMessage:(NSString *)message isConfirm:(BOOL)isConfirm confirmTitle:(NSString *)confirmTitle {
    CGFloat width = 280;
    CGFloat height = isConfirm ? 120 : 50;
    CGRect frame = CGRectMake(0, 0, width, height);
    
    self = [super initWithFrame:frame];
    if (self) {
        // 设置居中位置
        self.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        
        // 设置圆角和阴影
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 4;
        
        // 创建背景效果
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = self.bounds;
        effectView.layer.cornerRadius = 15;
        effectView.layer.masksToBounds = YES;
        [self addSubview:effectView];
        
        // 文本标签
        CGFloat messageHeight = isConfirm ? 60 : height;
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width - 40, messageHeight)];
        _messageLabel.text = message;
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        [effectView.contentView addSubview:_messageLabel];
        
        if (isConfirm) {
            // 分隔线
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, messageHeight, width, 1)];
            separator.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
            [effectView.contentView addSubview:separator];
            
            // 确认按钮
            UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
            confirmButton.frame = CGRectMake(0, messageHeight + 1, width, height - messageHeight - 1);
            [confirmButton setTitle:confirmTitle ?: @"确定" forState:UIControlStateNormal];
            [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            [confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [effectView.contentView addSubview:confirmButton];
        }
        
        // 创建窗口
        _alertWindow = [[AlertWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

- (void)confirmButtonTapped {
    if (self.confirmAction) {
        self.confirmAction();
    }
    [self dismiss];
}

- (void)show {
    if (!self.alertWindow) return;
    
    [self.alertWindow addSubview:self];
    self.alertWindow.hidden = NO;
    
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.8 
          initialSpringVelocity:0.5 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    if (!self.confirmAction) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismiss];
        });
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
    }];
}

@end 