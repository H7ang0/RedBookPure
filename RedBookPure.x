#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "ReadBookPureSettingsViewController.h"
#import <objc/runtime.h>
#import "PureLang.h"
#import "_TtP12XYNoteModels18CommentBrowserItem_-Protocol.h"
#import "ThemeManager.h"
#import "AlertManager.h"

// 添加完整的类声明
@interface XHSTabBarItem : UITabBarItem
@property (nonatomic, copy) NSString *title;
- (NSString *)imageNameForTabBarItem;
- (NSString *)selectedImageNameForTabBarItem;
@end

@interface XHSInteractionButton : UIButton
@property (nonatomic, assign) NSInteger tag;
- (NSString *)imageNameForButtonType:(NSInteger)type state:(UIControlState)state;
@end

@interface XHSNoteEditorToolbar : UIView
- (NSString *)imageNameForEditorButton:(NSInteger)buttonType;
@end

// 添加 UIBarButtonItem 的分类
@interface UIBarButtonItem (ThemeAdditions)
- (NSString *)imageNameForBarButtonItem;
@end

// 添加主题相关函数声明
static UIImage* loadThemeImage(NSString *imageName) {
    if (!imageName) return nil;
    
    ThemeManager *manager = [ThemeManager sharedManager];
    NSString *currentTheme = manager.currentThemeName;
    
    if (!currentTheme) {
        return nil;
    }
    
    NSString *themePath = [[manager themeDirectory] stringByAppendingPathComponent:currentTheme];
    if (![[NSFileManager defaultManager] fileExistsAtPath:themePath]) {
        return nil;
    }
    
    // 尝试加载图片
    NSString *imagePath = [themePath stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (!image) {
        // 尝试加载@2x和@3x版本
        NSString *image2xPath = [themePath stringByAppendingPathComponent:[imageName stringByReplacingOccurrencesOfString:@".png" withString:@"@2x.png"]];
        NSString *image3xPath = [themePath stringByAppendingPathComponent:[imageName stringByReplacingOccurrencesOfString:@".png" withString:@"@3x.png"]];
        
        image = [UIImage imageWithContentsOfFile:image2xPath];
        if (!image) {
            image = [UIImage imageWithContentsOfFile:image3xPath];
        }
    }
    
    return image;
}

// XYTabBar 声明
@interface XYTabBar : UIView
@property (nonatomic, strong) NSArray<UIView *> *subviews;
- (UILabel *)findLabelInView:(UIView *)view;
- (void)redistributeTabBarButtons;
@end

// XYTabBar 分类
@interface XYTabBar (Layout)
- (UILabel *)findLabelInView:(UIView *)view;
- (void)redistributeTabBarButtons;
@end

@interface XYTabBar (Additions)
- (BOOL)isShoppingTab:(UIView *)view;
- (BOOL)isPostTab:(UIView *)view;
@end

// 添加基础类声明
@interface XYPHNoteComment : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UIViewController *viewController;  // 添加一个属性来持有 viewController
- (void)showTips:(NSString *)message;
@end

@interface XYPHNoteComment (ErrorHandling)
- (void)showErrorAlert:(NSString *)message;
@end

@interface XYPHNoteCommentCell : UITableViewCell
@property (nonatomic, strong) XYPHNoteComment *comment;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *translateButton;
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
- (void)setupTranslateButton;
- (void)updateTranslateButtonFrame;
- (void)translateText:(NSString *)text completion:(void(^)(NSString *, NSError *))completion;
- (void)translateUsingSystem:(NSString *)text completion:(void(^)(NSString *, NSError *))completion;
- (void)translateUsingYoudao:(NSString *)text completion:(void(^)(NSString *, NSError *))completion;
- (void)translateUsingBaidu:(NSString *)text completion:(void(^)(NSString *, NSError *))completion;
- (void)translateUsingMicrosoft:(NSString *)text completion:(void(^)(NSString *, NSError *))completion;
- (void)showTranslationResult:(NSString *)translatedText;
- (void)showErrorAlert:(NSString *)message;
- (UIViewController *)topViewController;
@end

@interface XYActionSheetView : UIView
@end

@interface XYPHNoteComment (Translation)
@property (nonatomic, strong) UILongPressGestureRecognizer *translationGesture;
@property (nonatomic, strong) id translator;
@property (nonatomic, strong) UIView *contentView;
@end

@interface XHSSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
- (NSString *)_printViewHierarchy:(UIView *)view level:(int)level;
@end

@interface XHSMeSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
- (NSString *)_printViewHierarchy:(UIView *)view level:(int)level;
@end

@interface XYPHSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
- (void)openPluginSettings;
- (NSString *)_printViewHierarchy:(UIView *)view level:(int)level;
@end

@interface XYNoteContentLabel : UILabel
@end

@interface XYCommentContentLabel : UILabel
@end

@interface XYUserNameLabel : UILabel
@end

@interface XYPHMediaSaveConfig : NSObject
- (void)setDisableWatermark:(BOOL)arg1;
- (void)setDisableSave:(BOOL)arg1;
@end

@interface XHSSettingsViewController : UIViewController
@end

@interface XHSMeViewController : UIViewController
@end

@interface XHSProfileSettingsViewController : UIViewController
@end

@interface XHSUserSettingsViewController : UIViewController
@end

@interface UIStatusBar : UIView
@end

@interface XYNoteTitleView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) id translator;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *translationGesture;
- (void)showCustomNoteTitleMenu;
- (void)translateText:(NSString *)text;
- (void)showTranslationResult:(NSString *)translatedText;
- (void)generateAISummary:(NSString *)text;
- (void)showTips:(NSString *)message;
- (UIViewController *)topViewController;
@end

@interface XYNoteContentView : UIView
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) id translator;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *translationGesture;
- (void)showTranslationMenuForText:(NSString *)text;
- (void)translateText:(NSString *)text toLanguage:(NSString *)languageCode withName:(NSString *)languageName;
- (void)showCustomNoteContentMenu;
- (void)showTranslationResult:(NSString *)translatedText;
- (void)generateAISummary:(NSString *)text;
- (void)shareContent:(NSString *)text;
- (void)showTips:(NSString *)message;
- (UIViewController *)topViewController;
@end

@interface XYVideoNoteView : UIView
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) id translator;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *translationGesture;
- (void)showCustomVideoNoteMenu;
- (void)downloadVideo;
- (void)extractAudio;
- (void)shareVideo;
- (void)copyVideoUrl;
- (void)showTips:(NSString *)message;
- (void)handleTranslationGesture:(UILongPressGestureRecognizer *)gesture;
- (void)showTranslationMenuForText:(NSString *)text;
- (void)translateText:(NSString *)text toLanguage:(NSString *)targetLanguage withName:(NSString *)languageName;
- (UIViewController *)topViewController;
@end

@interface XYCommentListCell : UITableViewCell
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *quickActionButton;
@property (nonatomic, strong) NSArray *gestureRecognizers;
@property (nonatomic, strong) id translator;
@property (nonatomic, strong, readwrite) UILongPressGestureRecognizer *translationGesture;
- (void)showCustomCommentMenu;
- (void)translateText:(NSString *)text;
- (void)showTranslationResult:(NSString *)translatedText;
- (void)generateAISummary:(NSString *)text;
- (void)shareComment:(NSString *)text;
- (void)showTips:(NSString *)message;
- (UIViewController *)topViewController;
@end

@interface UIViewController (ThemeRefresh)
- (void)recursiveRefreshView:(UIView *)view;
@end

%hook UIViewController

%new
- (BOOL)canBecomeFirstResponder {
    return YES;
}

%end

%ctor {
    NSLog(@"[小红书净化] 开始加载");
    
    // 打印所有可能的设置相关类名
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0) {
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        for (int i = 0; i < numClasses; i++) {
            NSString *className = NSStringFromClass(classes[i]);
            if ([className containsString:@"Setting"] || 
                [className containsString:@"XHS"] || 
                [className containsString:@"Profile"]) {
                NSLog(@"[小红书净化] 发现潜在类: %@", className);
            }
        }
        
        free(classes);
    }
    
    // 监听主题变化通知
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ThemeDidChangeNotification"
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *note) {
        NSLog(@"[RedBookPure] 收到主题变化通知");
        
        // 清除图片缓存
        if (@available(iOS 13.0, *)) {
            [UIImage systemImageNamed:@""]; // 触发图片缓存清理
        }
        
        // 遍历所有窗口
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            // 刷新TabBar
            UITabBarController *tabBarController = (UITabBarController *)window.rootViewController;
            if ([tabBarController isKindOfClass:[UITabBarController class]]) {
                // 刷新TabBar图标
                [tabBarController.tabBar setNeedsLayout];
                [tabBarController.tabBar layoutIfNeeded];
                
                // 刷新每个Tab的导航栏
                for (UIViewController *viewController in tabBarController.viewControllers) {
                    if ([viewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *navController = (UINavigationController *)viewController;
                        [navController.navigationBar setNeedsLayout];
                        [navController.navigationBar layoutIfNeeded];
                    }
                }
            }
            
            // 递归刷新所有视图
            [(UIViewController *)window.rootViewController recursiveRefreshView:window.rootViewController.view];
        }
        
        NSLog(@"[RedBookPure] 主题刷新完成");
    }];
}

%hook XHSSettingViewController

%end

%hook XYPHSettingViewController

- (void)viewDidLoad {
    %orig;
}

%new
- (void)openPluginSettings {
    // 直接打开 ReadBookPureSettingsViewController
    [ReadBookPureSettingsViewController showSettings];
}

%end

%hook XYNoteContentLabel

%end

%hook XYCommentContentLabel

%end

%hook XYPHNoteComment

%end

%hook XYTabBar

- (void)layoutSubviews {
    %orig;
    
    // 获取设置
    BOOL removeShoppingTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_shopping"];
    BOOL removePostTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_post"];
    
    if (!removeShoppingTab && !removePostTab) return;
    
    // 延迟执行以确保所有子视图都已加载
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 遍历所有子视图
        for (UIView *view in self.subviews) {
            // 检查是否是标签按钮
            if ([NSStringFromClass([view class]) containsString:@"TabBarButton"]) {
                UILabel *label = [self findLabelInView:view];
                if (!label) continue;
                
                // 检查标签文字
                NSString *title = label.text;
                if (!title) continue;
                
                // 移除购物标签
                if (removeShoppingTab && ([title containsString:@"购物"] || 
                                        [title containsString:@"商城"] || 
                                        [title containsString:@"商品"])) {
                    view.hidden = YES;
                    view.alpha = 0;
                    [view removeFromSuperview];
                    continue;
                }
                
                // 移除发布按钮
                if (removePostTab && ([title containsString:@"发布"] || 
                                    [title containsString:@"+"] || 
                                    [title containsString:@"拍摄"])) {
                    view.hidden = YES;
                    view.alpha = 0;
                    [view removeFromSuperview];
                    continue;
                }
            }
        }
        
        // 重新布局剩余的标签
        [self redistributeTabBarButtons];
    });
}

%new
- (UILabel *)findLabelInView:(UIView *)view {
    // 递归查找 UILabel
    if ([view isKindOfClass:[UILabel class]]) {
        return (UILabel *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UILabel *label = [self findLabelInView:subview];
        if (label) {
            return label;
        }
    }
    
    return nil;
}

%new
- (void)redistributeTabBarButtons {
    NSMutableArray *visibleButtons = [NSMutableArray array];
    
    // 收集所有可见的标签按钮
    for (UIView *view in self.subviews) {
        if ([NSStringFromClass([view class]) containsString:@"TabBarButton"] && 
            !view.hidden && 
            view.superview) {
            [visibleButtons addObject:view];
        }
    }
    
    // 重新计算布局
    if (visibleButtons.count > 0) {
        CGFloat width = self.frame.size.width / visibleButtons.count;
        CGFloat height = self.frame.size.height;
        
        [visibleButtons enumerateObjectsUsingBlock:^(UIView *button, NSUInteger idx, BOOL *stop) {
            CGRect frame = button.frame;
            frame.origin.x = width * idx;
            frame.size.width = width;
            frame.size.height = height;
            button.frame = frame;
        }];
    }
}

%end

%hook XYPHMediaSaveConfig

// 增强去水印方法兼容性
- (BOOL)disableWatermark {
    @try {
        // 新版增加类型检查
        if ([self respondsToSelector:@selector(disableWatermark)]) {
            return YES;
        }
        return %orig;
    } @catch (NSException *e) {
        NSLog(@"[安全] 去水印异常: %@", e);
        return YES; // 异常时强制返回YES
    }
}

// 适配新版设置方法
- (void)setDisableWatermark:(BOOL)arg1 {
    %orig(YES); // 强制覆盖为YES
}

// 新增实况水印专用方法
- (BOOL)disableLivePhotoWatermark {
    return YES;
}

// 修复保存限制方法
- (void)setDisableSave:(BOOL)arg1 {
    %orig(NO); // 强制允许保存
}

%end

%hook UIImage

+ (UIImage *)imageNamed:(NSString *)name {
    // 尝试加载主题图片
    UIImage *themeImage = loadThemeImage(name);
    if (themeImage) {
        return themeImage;
    }
    
    // 如果没有主题图片，使用原始图片
    return %orig;
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path {
    UIImage *image = %orig;
    if (!image) {
        // 检查是否是主题图片路径
        if ([path containsString:@"RedTheme"]) {
            NSLog(@"[RedBookPure] 加载主题图片失败: %@", path);
        }
    }
    return image;
}

%end

// Hook 底部 TabBar 图标
%hook XHSTabBarItem

- (void)setImage:(UIImage *)image {
    NSString *imageName = [self imageNameForTabBarItem];
    if (imageName) {
        UIImage *themeImage = loadThemeImage(imageName);
        if (themeImage) {
            %orig(themeImage);
            return;
        }
    }
    %orig;
}

- (void)setSelectedImage:(UIImage *)image {
    NSString *imageName = [self selectedImageNameForTabBarItem];
    if (imageName) {
        UIImage *themeImage = loadThemeImage(imageName);
        if (themeImage) {
            %orig(themeImage);
            return;
        }
    }
    %orig;
}

%end

%hook XHSInteractionButton

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    NSString *imageName = [self imageNameForButtonType:self.tag state:state];
    if (imageName) {
        UIImage *themeImage = loadThemeImage(imageName);
        if (themeImage) {
            %orig(themeImage, state);
            return;
        }
    }
    %orig;
}

%end

%hook UIBarButtonItem

- (void)setImage:(UIImage *)image {
    NSString *imageName = [self imageNameForBarButtonItem];
    if (imageName) {
        UIImage *themeImage = loadThemeImage(imageName);
        if (themeImage) {
            %orig(themeImage);
            return;
        }
    }
    %orig;
}

%end


