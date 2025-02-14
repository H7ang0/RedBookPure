#import "ThemeSettingsViewController.h"
#import "ThemeManager.h"

@interface ThemeSettingsViewController ()
@property (nonatomic, strong) NSArray *themes;
@end

@implementation ThemeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主题设置";
    [self setupTableView];
    [self loadThemes];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)loadThemes {
    NSString *themePath = [[ThemeManager sharedManager] themeDirectory];
    NSError *error = nil;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:themePath error:&error];
    
    if (error) {
        NSLog(@"[RedBookPure] 加载主题列表失败: %@", error);
        self.themes = @[];
        return;
    }
    
    // 过滤出有效的主题文件夹（包含icon.png的文件夹）
    NSMutableArray *validThemes = [NSMutableArray array];
    for (NSString *item in contents) {
        NSString *iconPath = [themePath stringByAppendingPathComponent:[item stringByAppendingPathComponent:@"icon.png"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
            [validThemes addObject:item];
        }
    }
    
    self.themes = validThemes;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.themes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"ThemeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSString *themeName = self.themes[indexPath.row];
    cell.textLabel.text = themeName;
    
    // 加载主题预览图标
    NSString *iconPath = [[[ThemeManager sharedManager] themeDirectory] stringByAppendingPathComponent:[themeName stringByAppendingPathComponent:@"icon.png"]];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:iconPath];
    cell.imageView.image = iconImage;
    
    // 检查是否是当前主题
    if ([[ThemeManager sharedManager].currentThemeName isEqualToString:themeName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *themeName = self.themes[indexPath.row];
    
    // 检查是否已经应用了该主题
    if ([[ThemeManager sharedManager].currentThemeName isEqualToString:themeName]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" 
                                                                     message:@"当前已经应用该主题" 
                                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 显示确认对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"应用主题" 
                                                                 message:[NSString stringWithFormat:@"是否应用主题\"%@\"？", themeName]
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" 
                                            style:UIAlertActionStyleDefault 
                                          handler:^(UIAlertAction * _Nonnull action) {
        [[ThemeManager sharedManager] applyTheme:themeName];
        [self.tableView reloadData];
        
        // 提示需要重启应用
        UIAlertController *restartAlert = [UIAlertController alertControllerWithTitle:@"提示" 
                                                                            message:@"主题已应用，重启应用后生效" 
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [restartAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:restartAlert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end 