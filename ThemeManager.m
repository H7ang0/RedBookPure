#import "ThemeManager.h"

@interface ThemeManager ()
@property (nonatomic, copy, readwrite) NSString *currentThemeName;
@end

@implementation ThemeManager

static ThemeManager *_sharedManager = nil;

+ (instancetype)sharedManager {
    static ThemeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ThemeManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentThemeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_theme"];
        [self createThemeDirectoryIfNeeded];
    }
    return self;
}

- (void)createThemeDirectoryIfNeeded {
    NSString *themePath = [self themeDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:themePath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:themePath
                withIntermediateDirectories:YES
                                attributes:nil
                                    error:&error];
        if (error) {
            NSLog(@"[RedBookPure] 创建主题目录失败: %@", error);
        }
    }
}

- (NSString *)themeDirectory {
    NSString *basePath;
    BOOL isJailbroken = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    
    if (isJailbroken) {
        basePath = @"/var/mobile/Documents";
    } else {
        basePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    }
    
    return [basePath stringByAppendingPathComponent:@"DisCoverTheme"];
}

- (void)setCurrentTheme:(NSString *)themeName {
    if (!themeName) return;
    
    _currentThemeName = [themeName copy];
    [[NSUserDefaults standardUserDefaults] setObject:themeName forKey:@"current_theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ThemeDidChangeNotification" object:nil];
}

- (void)applyTheme:(NSString *)themeName {
    // 检查主题是否已安装
    if (![ThemeManager isThemeInstalled:themeName]) {
        NSLog(@"[RedBookPure] 主题未安装: %@", themeName);
        return;
    }
    
    // 设置当前主题
    [self setCurrentTheme:themeName];
}

+ (NSArray *)getInstalledThemes {
    NSString *themePath = [[ThemeManager sharedManager] themeDirectory];
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePath error:&error];
    
    if (error) {
        NSLog(@"[RedBookPure] 读取主题目录失败: %@", error);
        return @[];
    }
    
    NSMutableArray *themes = [NSMutableArray array];
    for (NSString *item in contents) {
        if ([item hasPrefix:@"."]) continue;
        
        NSString *itemPath = [themePath stringByAppendingPathComponent:item];
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:itemPath isDirectory:&isDirectory] && isDirectory) {
            [themes addObject:item];
        }
    }
    
    return themes;
}

+ (BOOL)isThemeInstalled:(NSString *)themeName {
    if (!themeName) return NO;
    
    NSString *themePath = [[[ThemeManager sharedManager] themeDirectory] stringByAppendingPathComponent:themeName];
    BOOL isDirectory = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:themePath isDirectory:&isDirectory] && isDirectory;
}

@end