#import <Foundation/Foundation.h>

@interface LicenseManager : NSObject

+ (instancetype)sharedManager;

// 验证授权
- (BOOL)verifyLicense:(NSString *)redBookId code:(NSString *)activationCode;

// 获取授权状态
- (BOOL)isActivated;

// 获取已授权的小红书ID
- (NSString *)getActivatedRedBookId;

@end 