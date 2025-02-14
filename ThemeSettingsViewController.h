#ifndef ThemeSettingsViewController_h
#define ThemeSettingsViewController_h

#import <UIKit/UIKit.h>

@interface ThemeSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *installedThemes;
@property (nonatomic, strong) UITableView *tableView;

@end

#endif /* ThemeSettingsViewController_h */ 