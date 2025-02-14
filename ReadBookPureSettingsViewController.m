#import "ReadBookPureSettingsViewController.h"
#import "UIButton+Layout.h"
#import "ThemeSettingsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>  // 用于 kUTTypeData
#import "LicenseManager.h"
#import "PureLang.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>  // 添加WebKit导入
#import <CoreMotion/CoreMotion.h>
#import "AlertManager.h"
#import "ThemeManager.h"

@interface ReadBookPureSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *settingItems;
@property (nonatomic, strong) UIVisualEffectView *bottomBar;
@property (nonatomic, strong) UIStackView *buttonStackView;
@property (nonatomic, strong) NSArray *installedThemes;
@end

@implementation ReadBookPureSettingsViewController

+ (void)showSettings {
    ReadBookPureSettingsViewController *settingsVC = [[ReadBookPureSettingsViewController alloc] init];
    
    // 获取当前窗口的新方法
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = UIApplication.sharedApplication.connectedScenes;
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [[UIApplication sharedApplication] keyWindow];
#pragma clang diagnostic pop
    }
    
    UIViewController *topVC = window.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)topVC pushViewController:settingsVC animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [topVC presentViewController:nav animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 确保主题目录存在
    [self createThemeDirectoryIfNeeded];
    
    // 设置标题
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:@"小红书净化"];
    [titleText addAttribute:NSForegroundColorAttributeName 
                     value:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0] 
                     range:NSMakeRange(0, titleText.length)];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = titleText;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
    
    // 修改设置项，保留主题功能
    [self setupOptions];
    
    [self setupTableView];
    [self setupBottomBar];
    
    // 设置导航栏外观
    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.standardAppearance = [self ReadBookPureNavigationBarAppearance];
        self.navigationController.navigationBar.scrollEdgeAppearance = [self ReadBookPureNavigationBarAppearance];
    }
    
    // 如果是被push进来的，不需要添加关闭按钮
    if (self.navigationController.viewControllers.count == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(dismissSettings)];
        // 设置按钮颜色为粉色
        closeButton.tintColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
        self.navigationItem.rightBarButtonItem = closeButton;
    }
}

- (void)createThemeDirectoryIfNeeded {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *themePath = [documentsPath stringByAppendingPathComponent:@"DisCoverTheme"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:themePath isDirectory:&isDirectory];
    
    if (!exists || !isDirectory) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:themePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"[RedBookPure] 创建主题目录失败: %@", error);
        } else {
            NSLog(@"[RedBookPure] 成功创建主题目录: %@", themePath);
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)showTranslateInputAlert {
    // 方法已移除，留空或删除
}

- (void)translateText:(NSString *)text {
    // 方法已移除，留空或删除
}

- (void)showTranslationResult:(NSString *)originalText translated:(NSString *)translatedText {
    // 方法已移除，留空或删除
}

- (UINavigationBarAppearance *)ReadBookPureNavigationBarAppearance API_AVAILABLE(ios(13.0)) {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithDefaultBackground];
    appearance.backgroundColor = [UIColor systemBackgroundColor];
    return appearance;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0); // 为底部栏留出空间
    [self.view addSubview:self.tableView];
}

- (void)setupBottomBar {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    self.bottomBar = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    // 调整底栏位置和大小
    CGFloat bottomBarHeight = 70;
    CGFloat bottomPadding = self.view.safeAreaInsets.bottom;
    
    CGRect frame = CGRectMake(16,
                             self.view.bounds.size.height - bottomBarHeight - bottomPadding - 16,
                             self.view.bounds.size.width - 32,
                             bottomBarHeight);
    
    self.bottomBar.frame = frame;
    // 设置为完全圆角
    self.bottomBar.layer.cornerRadius = bottomBarHeight / 2;
    self.bottomBar.clipsToBounds = YES;
    
    // 创建三个按钮
    UIButton *resetButton = [self createBottomButton:@"重置" icon:@"arrow.counterclockwise" action:@selector(resetSettings)];
    UIButton *themeButton = [self createBottomButton:@"主题" icon:@"paintbrush.fill" action:@selector(showThemeSettings)];
    UIButton *aboutButton = [self createBottomButton:@"关于" icon:@"info.circle" action:@selector(showAbout)];
    
    // 设置按钮位置
    CGFloat buttonWidth = frame.size.width / 3;
    resetButton.frame = CGRectMake(0, 0, buttonWidth, bottomBarHeight);
    themeButton.frame = CGRectMake(buttonWidth, 0, buttonWidth, bottomBarHeight);
    aboutButton.frame = CGRectMake(buttonWidth * 2, 0, buttonWidth, bottomBarHeight);
    
    [self.bottomBar.contentView addSubview:resetButton];
    [self.bottomBar.contentView addSubview:themeButton];
    [self.bottomBar.contentView addSubview:aboutButton];
    
    [self.view addSubview:self.bottomBar];
}

- (UIButton *)createBottomButton:(NSString *)title icon:(NSString *)iconName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    if (@available(iOS 13.0, *)) {
        UIImage *icon = [UIImage systemImageNamed:iconName];
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightRegular];
        icon = [icon imageByApplyingSymbolConfiguration:config];
        [button setImage:icon forState:UIControlStateNormal];
    }
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    
    // 调整图标和文字间距
    [button centerImageAndTitle:4.0];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Actions

- (void)resetSettings {
    // 保留原始实现，删除%orig语句
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"remove_save_watermark"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"force_save_media"];
    // ...其他重置逻辑...
}

- (void)shareSettings {
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for (NSDictionary *item in self.settingItems) {
        settings[item[@"key"]] = @([[NSUserDefaults standardUserDefaults] boolForKey:item[@"key"]]);
    }
    
    NSString *settingsString = [NSString stringWithFormat:@"RedBookPure 设置:\n%@", settings.description];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[settingsString]
                                                                         applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)showAbout {
    UIViewController *aboutVC = [[UIViewController alloc] init];
    aboutVC.view.backgroundColor = [UIColor systemBackgroundColor];
    aboutVC.title = @"关于";
    
    // 创建滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:aboutVC.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [aboutVC.view addSubview:scrollView];
    
    // 创建内容视图
    UIView *contentView = [[UIView alloc] initWithFrame:scrollView.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [scrollView addSubview:contentView];
    
    // 图标
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.bounds.size.width - 60) / 2, 20, 60, 60)];
    if (@available(iOS 13.0, *)) {
        iconView.image = [UIImage systemImageNamed:@"sparkles"];
        iconView.tintColor = [UIColor systemBlueColor];
    }
    [contentView addSubview:iconView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, contentView.bounds.size.width, 30)];
    titleLabel.text = @"RedBookPure";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [contentView addSubview:titleLabel];
    
    // 版本号
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, contentView.bounds.size.width, 20)];
    versionLabel.text = @"Version 1.0.5";
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor secondaryLabelColor];
    versionLabel.font = [UIFont systemFontOfSize:14];
    [contentView addSubview:versionLabel];
    
    // 描述
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, contentView.bounds.size.width - 40, 40)];
    descLabel.text = @"小红书净化";
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.numberOfLines = 0;
    [contentView addSubview:descLabel];
    
    // 分隔线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(20, 200, contentView.bounds.size.width - 40, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    [contentView addSubview:separator];
    
    // 加载credits.json内容
    __block CGFloat currentY = 220;  // 修改为__block类型
    NSURL *creditsURL = [NSURL URLWithString:@"https://youkebing.com/credits.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:creditsURL];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示credits内容
                if (json[@"credits"]) {
            UILabel *creditsTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, currentY, contentView.bounds.size.width - 40, 30)];
                    creditsTitle.text = @"致谢";
                    creditsTitle.font = [UIFont boldSystemFontOfSize:18];
            [contentView addSubview:creditsTitle];
                    
                    CGFloat y = currentY + 40;
                    for (NSDictionary *credit in json[@"credits"]) {
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, contentView.bounds.size.width - 40, 40)];
                        label.text = [NSString stringWithFormat:@"%@: %@", credit[@"name"], credit[@"description"]];
                        label.numberOfLines = 0;
                        [contentView addSubview:label];
                        y += 50;
                    }
                    currentY = y + 20;
                }
                
                // 显示contributors内容
                if (json[@"contributors"]) {
            UILabel *contributorsTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, currentY, contentView.bounds.size.width - 40, 30)];
                    contributorsTitle.text = @"贡献者";
                    contributorsTitle.font = [UIFont boldSystemFontOfSize:18];
            [contentView addSubview:contributorsTitle];
                    
                    CGFloat y = currentY + 40;
                    for (NSDictionary *contributor in json[@"contributors"]) {
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, contentView.bounds.size.width - 40, 40)];
                        label.text = [NSString stringWithFormat:@"%@: %@", contributor[@"name"], contributor[@"description"]];
                        label.numberOfLines = 0;
                        [contentView addSubview:label];
                        y += 50;
                    }
                    currentY = y + 20;
                }
                
                // 显示donators内容
                if (json[@"donators"]) {
            UILabel *donatorsTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, currentY, contentView.bounds.size.width - 40, 30)];
                    donatorsTitle.text = @"赞助者";
                    donatorsTitle.font = [UIFont boldSystemFontOfSize:18];
            [contentView addSubview:donatorsTitle];
                    
                    CGFloat y = currentY + 40;
                    for (NSDictionary *donator in json[@"donators"]) {
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, contentView.bounds.size.width - 40, 40)];
                        label.text = [NSString stringWithFormat:@"%@ %@: %@", donator[@"name"], donator[@"amount"], donator[@"message"]];
                        label.numberOfLines = 0;
                        [contentView addSubview:label];
                        y += 50;
                    }
                    currentY = y + 20;
                }
                
                // 底部按钮栏
                UIView *buttonBar = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, contentView.bounds.size.width, 80)];
                [contentView addSubview:buttonBar];
                
                // Telegram群组按钮
                UIButton *telegramButton = [UIButton buttonWithType:UIButtonTypeSystem];
                telegramButton.frame = CGRectMake(20, 0, (contentView.bounds.size.width - 60) / 2, 44);
                [telegramButton setTitle:@"Telegram 群组" forState:UIControlStateNormal];
                telegramButton.layer.cornerRadius = 8;
                telegramButton.layer.borderWidth = 1;
                telegramButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
                [telegramButton addTarget:self action:@selector(openTelegram) forControlEvents:UIControlEventTouchUpInside];
                [buttonBar addSubview:telegramButton];
                
                // 捐赠按钮
                UIButton *donateButton = [UIButton buttonWithType:UIButtonTypeSystem];
                donateButton.frame = CGRectMake(contentView.bounds.size.width/2 + 10, 0, (contentView.bounds.size.width - 60) / 2, 44);
                [donateButton setTitle:@"请我喝杯咖啡" forState:UIControlStateNormal];
                donateButton.backgroundColor = [UIColor systemBlueColor];
                [donateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                donateButton.layer.cornerRadius = 8;
                [donateButton addTarget:self action:@selector(showDonation) forControlEvents:UIControlEventTouchUpInside];
                [buttonBar addSubview:donateButton];
                
                // 更新contentView和scrollView的大小
                CGRect frame = contentView.frame;
                frame.size.height = currentY + 100;
                contentView.frame = frame;
                scrollView.contentSize = frame.size;
            });
        }
    }] resume];
    
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)openTelegram {
    NSURL *telegramURL = [NSURL URLWithString:@"https://t.me/HyanguChat"];
    [[UIApplication sharedApplication] openURL:telegramURL options:@{} completionHandler:nil];
}

- (void)showDonation {
    UIViewController *donateVC = [[UIViewController alloc] init];
    donateVC.view.backgroundColor = [UIColor systemBackgroundColor];
    donateVC.title = @"赞赏支持";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:donateVC.view.bounds];
    [donateVC.view addSubview:scrollView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, donateVC.view.bounds.size.width - 40, 60)];
    titleLabel.text = @"如果您觉得内容对您有帮助，欢迎赞赏支持！";
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:titleLabel];
    
    // 加载捐赠二维码
    NSURL *payURL = [NSURL URLWithString:@"https://youkebing.com/pay/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:payURL];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 100, donateVC.view.bounds.size.width, donateVC.view.bounds.size.height - 100)];
    [webView loadRequest:request];
    [scrollView addSubview:webView];
    
    [self.navigationController pushViewController:donateVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingItems[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.settingItems[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *item = self.settingItems[indexPath.section][@"items"][indexPath.row];
    cell.textLabel.text = item[@"title"];
    
    if (@available(iOS 13.0, *)) {
        cell.imageView.image = [UIImage systemImageNamed:item[@"icon"]];
    }
    
    // 根据类型设置不同的样式
    NSString *type = item[@"type"];
    if ([type isEqualToString:@"switch"]) {
        // 开关类型
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:item[@"key"]];
        switchView.tag = indexPath.row;
        [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([type isEqualToString:@"push"]) {
        // 进入类型（主题设置、赞赏等）
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

// 开关变化处理
- (void)switchChanged:(UISwitch *)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) return;
    
    NSDictionary *item = self.settingItems[indexPath.section][@"items"][indexPath.row];
    NSString *key = item[@"key"];
    BOOL isOn = sender.isOn;
    
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *title = item[@"title"];
    NSString *message = [NSString stringWithFormat:@"已%@%@", isOn ? @"开启" : @"关闭", title];
    [CustomToastView showConfirmToast:message confirmTitle:@"确定" confirmAction:^{
        [self showRestartAlert];
    }];
}

- (void)showTranslateSourceSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择翻译源"
                                                                 message:@"请选择要使用的翻译服务"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"系统翻译"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"translate_source"];
        [CustomToastView showToast:@"已设置为系统翻译"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"有道翻译"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"translate_source"];
        [CustomToastView showToast:@"已设置为有道翻译"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"百度翻译"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"translate_source"];
        [CustomToastView showToast:@"已设置为百度翻译"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"微软翻译"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"translate_source"];
        [CustomToastView showToast:@"已设置为微软翻译"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    
    // iPad 支持
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                   self.view.bounds.size.height / 2, 
                                                                   0, 
                                                                   0);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showYoudaoSettings {
    // 方法已移除，留空或删除
}

- (void)showBaiduSettings {
    // 方法已移除，留空或删除
}

- (void)showMicrosoftSettings {
    // 方法已移除，留空或删除
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        [self.tableView reloadData];
    }
}

+ (void)translateText:(NSString *)text completion:(void(^)(NSString *translatedText))completion {
    // 方法已移除，留空或删除
}

+ (NSString *)themeDirectory {
    // 获取Documents目录路径
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *themePath = [documentsPath stringByAppendingPathComponent:@"DisCoverTheme"];
    
    // 检查是否是越狱设备
    BOOL isJailbroken = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    if (isJailbroken) {
        // 越狱设备使用固定路径
        themePath = @"/var/mobile/Documents/DisCoverTheme";
    }
    
    // 创建主题目录
    if (![[NSFileManager defaultManager] fileExistsAtPath:themePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:themePath
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                    error:&error];
        if (error) {
            NSLog(@"[RedBookPure] 创建主题目录失败: %@", error);
        } else {
            NSLog(@"[RedBookPure] 成功创建主题目录: %@", themePath);
        }
    }
    
    return themePath;
}

+ (NSArray *)getInstalledThemes {
    NSString *themePath = [self themeDirectory];
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePath error:&error];
    
    if (error) {
        return @[];
    }
    
    return [contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject pathExtension] isEqualToString:@"theme"];
    }]];
}

+ (void)applyTheme:(NSString *)themeName {
    if ([themeName isEqualToString:[ThemeManager sharedManager].currentThemeName]) {
        [CustomToastView showToast:@"当前已经是这个主题了"];
        return;
    }
    
    NSString *themePath = [[ThemeManager sharedManager].themeDirectory stringByAppendingPathComponent:themeName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:themePath]) {
        [CustomToastView showToast:@"读取主题文件失败"];
        return;
    }
    
    // 检查主题图标是否存在
    BOOL hasIcons = NO;
    NSArray *themeFiles = [fileManager contentsOfDirectoryAtPath:themePath error:nil];
    for (NSString *file in themeFiles) {
        if ([file hasSuffix:@".png"] || [file hasSuffix:@".jpg"]) {
            hasIcons = YES;
            break;
        }
    }
    
    if (hasIcons) {
        [[ThemeManager sharedManager] setCurrentTheme:themeName];
        [CustomToastView showToast:@"主题应用成功，请重启应用"];
    } else {
        [CustomToastView showToast:@"未找到可用的主题图标"];
    }
}

// 底部按钮布局
- (void)setupBottomButtons {
    CGFloat buttonHeight = 44;
    CGFloat buttonSpacing = 20;
    CGFloat bottomMargin = 34;
    
    // 主题按钮
    UIButton *themeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [themeButton setImage:[UIImage systemImageNamed:@"paintbrush.fill"] forState:UIControlStateNormal];
    [themeButton setTitle:@"主题" forState:UIControlStateNormal];
    themeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [themeButton addTarget:self action:@selector(themeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // 计算按钮宽度
    CGFloat buttonWidth = (self.view.frame.size.width - buttonSpacing * 3) / 2;
    
    themeButton.frame = CGRectMake(buttonSpacing,
                                  self.view.frame.size.height - bottomMargin - buttonHeight,
                                  buttonWidth,
                                  buttonHeight);
    
    [self.view addSubview:themeButton];
    
    // 分享按钮
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setImage:[UIImage systemImageNamed:@"square.and.arrow.up"] forState:UIControlStateNormal];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    shareButton.frame = CGRectMake(self.view.frame.size.width - buttonWidth - buttonSpacing,
                                  self.view.frame.size.height - bottomMargin - buttonHeight,
                                  buttonWidth,
                                  buttonHeight);
    
    [self.view addSubview:shareButton];
}

// 添加新的开关选项
- (void)addSwitchWithTitle:(NSString *)title key:(NSString *)key icon:(NSString *)iconName {
    NSMutableArray *items = [self.settingItems mutableCopy];
    [items addObject:@{
        @"title": title,
        @"key": key,
        @"icon": iconName
    }];
    self.settingItems = items;
    [self.tableView reloadData];
}

// 添加新的 TableView 代理方法处理点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.settingItems[indexPath.section][@"items"][indexPath.row];
    if ([item[@"type"] isEqualToString:@"push"]) {
        if ([item[@"key"] isEqualToString:@"theme_settings"]) {
            [self showThemeSettings];
        } else if ([item[@"key"] isEqualToString:@"donation"]) {
            [self showDonation];
        } else if ([item[@"key"] isEqualToString:@"block_keywords"]) {
            [self showKeywordBlockSettings];
        } else if ([item[@"key"] isEqualToString:@"block_regions"]) {
            [self showLocationBlockSettings];
        }
    }
}

// 修改内容屏蔽设置界面
- (void)showIPBlockSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"内容屏蔽"
                                                                 message:@"请选择屏蔽类型"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 关键词屏蔽选项
    [alert addAction:[UIAlertAction actionWithTitle:@"关键词屏蔽"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [self showKeywordBlockSettings];
    }]];
    
    // 发布地区屏蔽选项
    [alert addAction:[UIAlertAction actionWithTitle:@"发布地区屏蔽"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [self showLocationBlockSettings];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    // iPad 支持
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                   self.view.bounds.size.height / 2, 
                                                                   0, 
                                                                   0);
        alert.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 修改关键词屏蔽设置界面
- (void)showKeywordBlockSettings {
    UIViewController *keywordVC = [[UIViewController alloc] init];
    keywordVC.title = @"关键词屏蔽";
    keywordVC.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加说明文本
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"输入要屏蔽的关键词，每行一个";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor secondaryLabelColor];
    tipLabel.numberOfLines = 0;
    tipLabel.frame = CGRectMake(20, 20, keywordVC.view.bounds.size.width - 40, 40);
    [keywordVC.view addSubview:tipLabel];
    
    // 添加文本编辑框
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16];
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor separatorColor].CGColor;
    textView.layer.cornerRadius = 8;
    textView.frame = CGRectMake(20, CGRectGetMaxY(tipLabel.frame) + 10,
                               keywordVC.view.bounds.size.width - 40,
                               200);
    
    // 加载已保存的关键词
    NSString *blockedKeywords = [[NSUserDefaults standardUserDefaults] stringForKey:@"blocked_keywords"];
    textView.text = [blockedKeywords stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    
    [keywordVC.view addSubview:textView];
    
    // 添加保存按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor systemBlueColor];
    saveButton.layer.cornerRadius = 22;
    saveButton.frame = CGRectMake(20, CGRectGetMaxY(textView.frame) + 20,
                                 keywordVC.view.bounds.size.width - 40, 44);
    
    objc_setAssociatedObject(saveButton, "textView", textView, OBJC_ASSOCIATION_ASSIGN);
    [saveButton addTarget:self action:@selector(saveKeywordSettings:) forControlEvents:UIControlEventTouchUpInside];
    [keywordVC.view addSubview:saveButton];
    
    [self.navigationController pushViewController:keywordVC animated:YES];
}

- (void)saveKeywordSettings:(UIButton *)sender {
    UITextView *textView = objc_getAssociatedObject(sender, "textView");
    if (!textView) return;
    
    // 将换行符替换为逗号
    NSString *keywords = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    [[NSUserDefaults standardUserDefaults] setObject:keywords forKey:@"blocked_keywords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 显示保存成功提示
    [self showToast:@"保存成功" backgroundColor:[UIColor systemGreenColor]];
    
    // 返回上一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

// 修改地区屏蔽设置界面
- (void)showLocationBlockSettings {
    UIViewController *locationVC = [[UIViewController alloc] init];
    locationVC.title = @"地区屏蔽";
    locationVC.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加说明文本
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"输入要屏蔽的地区，每行一个\n例如：美国\n日本\n韩国";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor secondaryLabelColor];
    tipLabel.numberOfLines = 0;
    tipLabel.frame = CGRectMake(20, 20, locationVC.view.bounds.size.width - 40, 80);
    [locationVC.view addSubview:tipLabel];
    
    // 添加文本编辑框
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16];
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor separatorColor].CGColor;
    textView.layer.cornerRadius = 8;
    textView.frame = CGRectMake(20, CGRectGetMaxY(tipLabel.frame) + 10,
                               locationVC.view.bounds.size.width - 40,
                               200);
    
    // 加载已保存的地区
    NSString *blockedRegions = [[NSUserDefaults standardUserDefaults] stringForKey:@"blocked_ip_list"];
    textView.text = [blockedRegions stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    
    [locationVC.view addSubview:textView];
    
    // 添加保存按钮
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor systemBlueColor];
    saveButton.layer.cornerRadius = 22;
    saveButton.frame = CGRectMake(20, CGRectGetMaxY(textView.frame) + 20,
                                 locationVC.view.bounds.size.width - 40, 44);
    
    objc_setAssociatedObject(saveButton, "textView", textView, OBJC_ASSOCIATION_ASSIGN);
    [saveButton addTarget:self action:@selector(saveLocationSettings:) forControlEvents:UIControlEventTouchUpInside];
    [locationVC.view addSubview:saveButton];
    
    [self.navigationController pushViewController:locationVC animated:YES];
}

- (void)saveLocationSettings:(UIButton *)sender {
    UITextView *textView = objc_getAssociatedObject(sender, "textView");
    if (!textView) return;
    
    // 将换行符替换为逗号
    NSString *regions = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    [[NSUserDefaults standardUserDefaults] setObject:regions forKey:@"blocked_ip_list"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 显示保存成功提示
    [self showToast:@"保存成功" backgroundColor:[UIColor systemGreenColor]];
    
    // 返回上一页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

// 视频屏蔽设置
- (void)showVideoBlockSettings {
    BOOL currentSetting = [[NSUserDefaults standardUserDefaults] boolForKey:@"block_videos"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频屏蔽"
                                                                 message:@"是否屏蔽所有视频内容？"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:currentSetting ? @"关闭屏蔽" : @"开启屏蔽"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentSetting forKey:@"block_videos"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showRestartAlert];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 添加重启提示方法
- (void)showRestartAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                 message:@"设置已保存，请重启应用后生效"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" 
                                                      style:UIAlertActionStyleDefault 
                                                    handler:nil];
    [okAction setValue:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0] forKey:@"titleTextColor"];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 添加主题按钮点击方法
- (void)themeButtonTapped {
    [self showThemeSettings];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.installedThemes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeCell" forIndexPath:indexPath];
    
    // 显示主题预览图标
    NSString *themeName = self.installedThemes[indexPath.item];
    NSString *iconPath = [NSString stringWithFormat:@"/var/mobile/Documents/RedTheme/%@/icon.png", themeName];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    iconView.image = [UIImage imageWithContentsOfFile:iconPath];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 显示主题名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 40)];
    nameLabel.text = themeName;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:12];
    
    [cell.contentView addSubview:iconView];
    [cell.contentView addSubview:nameLabel];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *themeName = self.installedThemes[indexPath.item];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"应用主题"
                                                                 message:[NSString stringWithFormat:@"是否应用主题\"%@\"？", themeName]
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [self applyTheme:themeName];
    }]];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)importTheme {
    // 使用文件管理器直接访问文档目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *themesDirectory = [documentsDirectory stringByAppendingPathComponent:@"RedTheme"];
    
    // 确保主题目录存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:themesDirectory]) {
        [fileManager createDirectoryAtPath:themesDirectory 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:&error];
        if (error) {
            [self showErrorAlert:@"创建主题目录失败"];
            return;
        }
    }
    
    // 显示提示信息
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入主题"
                                                                 message:@"请将主题包放入以下目录：\n/var/mobile/Documents/RedTheme/"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 添加辅助方法
- (void)showErrorAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setupOptions {
    self.settingItems = @[
        @{@"title": @"核心功能", @"items": @[
            @{@"title": @"去除所有水印", @"key": @"remove_all_watermark", @"icon": @"drop", @"type": @"switch"},
            @{@"title": @"解除保存限制", @"key": @"bypass_save_restriction", @"icon": @"arrow.down.to.line", @"type": @"switch"},
            @{@"title": @"移除推荐标签", @"key": @"remove_recommend_tags", @"icon": @"tag.slash", @"type": @"switch"}
        ]},
        @{@"title": @"界面优化", @"items": @[
            @{@"title": @"简洁标签栏", @"key": @"clean_tabbar", @"icon": @"square.grid.2x2", @"type": @"switch"},
            @{@"title": @"主题设置", @"key": @"theme_settings", @"icon": @"paintbrush", @"type": @"push"}
        ]}
    ];
}

- (void)showActivation {
    // 在这里实现激活相关的逻辑
}

// 添加 Toast 提示方法
- (void)showToast:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    [CustomToastView showToast:message];
}

- (void)dismissSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showThemeSettings {
    UIViewController *themeVC = [[UIViewController alloc] init];
    themeVC.view.backgroundColor = [UIColor systemBackgroundColor];
    themeVC.title = @"主题设置";
    
    // 设置返回按钮颜色为粉色
    themeVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
        initWithTitle:@"返回"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(dismissThemeSettings)];
    themeVC.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
    
    // 创建滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:themeVC.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [themeVC.view addSubview:scrollView];
    
    // 创建说明标签
    UILabel *instructionLabel = [[UILabel alloc] init];
    instructionLabel.numberOfLines = 0;
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.font = [UIFont systemFontOfSize:14];
    
    // 判断是否越狱
    BOOL isJailbroken = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    if (isJailbroken) {
        instructionLabel.text = @"主题包存放路径：\n沙盒目录/DisCoverTheme";
    } else {
        instructionLabel.text = @"主题包存放路径：\n文件-我的iPhone-小红书-DisCoverTheme";
    }
    
    instructionLabel.frame = CGRectMake(20, 20, themeVC.view.bounds.size.width - 40, 60);
    [scrollView addSubview:instructionLabel];
    
    // 创建主题列表容器
    UIView *themesContainer = [[UIView alloc] init];
    themesContainer.frame = CGRectMake(0, CGRectGetMaxY(instructionLabel.frame) + 20, 
                                     themeVC.view.bounds.size.width,
                                     themeVC.view.bounds.size.height - CGRectGetMaxY(instructionLabel.frame) - 20);
    [scrollView addSubview:themesContainer];
    
    // 加载主题列表
    NSString *themePath = @"/var/mobile/Documents/DisCoverTheme";
    NSError *error;
    NSArray *themeDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePath error:&error];
    
    if (error) {
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.text = @"无法加载主题列表";
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.frame = CGRectMake(20, 0, themesContainer.bounds.size.width - 40, 40);
        [themesContainer addSubview:errorLabel];
    } else {
        // 创建主题网格布局
        CGFloat padding = 15;
        CGFloat itemWidth = (themesContainer.bounds.size.width - padding * 3) / 2;
        CGFloat itemHeight = 180;
        CGFloat currentX = padding;
        CGFloat currentY = 0;
        
        for (NSString *themeName in themeDirectories) {
            if ([themeName hasPrefix:@"."]) continue;
            
            // 创建主题项容器
            UIView *themeItem = [[UIView alloc] initWithFrame:CGRectMake(currentX, currentY, itemWidth, itemHeight)];
            themeItem.backgroundColor = [UIColor systemBackgroundColor];
            themeItem.layer.cornerRadius = 10;
            themeItem.layer.borderWidth = 1;
            themeItem.layer.borderColor = [UIColor systemGrayColor].CGColor;
            
            // 加载主题图标
            NSString *iconPath = [NSString stringWithFormat:@"%@/%@/icon.png", themePath, themeName];
            UIImage *iconImage = [UIImage imageWithContentsOfFile:iconPath];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, itemWidth - 20, itemWidth - 20)];
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.image = iconImage ?: [UIImage systemImageNamed:@"photo"];
            [themeItem addSubview:iconView];
            
            // 添加主题名称标签
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(iconView.frame) + 10, 
                                                                         itemWidth - 20, 20)];
            nameLabel.text = themeName;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.font = [UIFont systemFontOfSize:14];
            [themeItem addSubview:nameLabel];
            
            // 添加点击手势
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                initWithTarget:self action:@selector(themeItemTapped:)];
            themeItem.userInteractionEnabled = YES;
            [themeItem addGestureRecognizer:tapGesture];
            objc_setAssociatedObject(themeItem, "themeName", themeName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [themesContainer addSubview:themeItem];
            
            // 更新位置
            if (currentX + itemWidth + padding >= themesContainer.bounds.size.width) {
                currentX = padding;
                currentY += itemHeight + padding;
            } else {
                currentX += itemWidth + padding;
            }
        }
        
        // 更新滚动视图内容大小
        scrollView.contentSize = CGSizeMake(themesContainer.bounds.size.width,
                                          currentY + itemHeight + padding);
    }
    
    [self.navigationController pushViewController:themeVC animated:YES];
}

- (void)dismissThemeSettings {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)themeItemTapped:(UITapGestureRecognizer *)gesture {
    UIView *themeItem = gesture.view;
    NSString *themeName = objc_getAssociatedObject(themeItem, "themeName");
    
    if (!themeName) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"应用主题"
                                                                 message:[NSString stringWithFormat:@"是否应用主题\"%@\"？", themeName]
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        [self applyTheme:themeName];
    }]];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)applyTheme:(NSString *)themeName {
    if ([themeName isEqualToString:[ThemeManager sharedManager].currentThemeName]) {
        [CustomToastView showToast:@"当前已经是这个主题了"];
        return;
    }
    
    NSString *themePath = [[ThemeManager sharedManager].themeDirectory stringByAppendingPathComponent:themeName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:themePath]) {
        [CustomToastView showToast:@"读取主题文件失败"];
        return;
    }
    
    // 检查主题图标是否存在
    BOOL hasIcons = NO;
    NSArray *themeFiles = [fileManager contentsOfDirectoryAtPath:themePath error:nil];
    for (NSString *file in themeFiles) {
        if ([file hasSuffix:@".png"] || [file hasSuffix:@".jpg"]) {
            hasIcons = YES;
            break;
        }
    }
    
    if (hasIcons) {
        [[ThemeManager sharedManager] setCurrentTheme:themeName];
        [CustomToastView showToast:@"主题应用成功，请重启应用"];
    } else {
        [CustomToastView showToast:@"未找到可用的主题图标"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 检查是否启用摇一摇翻译
    BOOL shakeToTranslate = [[NSUserDefaults standardUserDefaults] boolForKey:@"shake_to_translate"];
    if (shakeToTranslate) {
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
        [self becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

@end 
