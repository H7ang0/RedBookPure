#ifndef ReadBookPureSettingsViewController_h
#define ReadBookPureSettingsViewController_h

#import <UIKit/UIKit.h>

@interface ReadBookPureSettingsViewController : UIViewController

+ (void)showSettings;
+ (NSArray *)getInstalledThemes;
- (void)setupOptions;
- (void)setupTableView;
- (void)setupBottomBar;
- (void)dismissSettings;
- (void)showToast:(NSString *)message backgroundColor:(UIColor *)backgroundColor;
- (void)showThemeSettings;
- (void)applyTheme:(NSString *)themeName;

@end

#endif /* ReadBookPureSettingsViewController_h */