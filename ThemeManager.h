#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

@property (nonatomic, copy, readonly) NSString *currentThemeName;

+ (instancetype)sharedManager;
- (NSString *)themeDirectory;
- (void)setCurrentTheme:(NSString *)themeName;
- (void)applyTheme:(NSString *)themeName;
+ (NSArray *)getInstalledThemes;
+ (BOOL)isThemeInstalled:(NSString *)themeName;

@end