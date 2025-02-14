#import "LicenseManager.h"
#import <CommonCrypto/CommonCrypto.h>

@interface LicenseManager()
@property (nonatomic, strong) NSString *secretKey;
@end

@implementation LicenseManager

+ (instancetype)sharedManager {
    static LicenseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LicenseManager alloc] init];
        manager.secretKey = @"YOUR_SECRET_KEY"; // 替换为你的密钥
    });
    return manager;
}

- (BOOL)verifyLicense:(NSString *)redBookId code:(NSString *)activationCode {
    // 验证参数
    if (!redBookId || !activationCode || 
        redBookId.length == 0 || activationCode.length == 0) {
        return NO;
    }
    
    // 生成预期的激活码
    NSString *expectedCode = [self generateActivationCode:redBookId];
    
    // 验证激活码
    if ([activationCode isEqualToString:expectedCode]) {
        // 保存授权信息
        [[NSUserDefaults standardUserDefaults] setObject:redBookId forKey:@"activated_redbook_id"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_activated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    return NO;
}

- (NSString *)generateActivationCode:(NSString *)redBookId {
    // 组合验证字符串
    NSString *content = [NSString stringWithFormat:@"%@_%@", redBookId, self.secretKey];
    
    // 计算MD5
    const char *cStr = [content UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    // 转换为hex字符串
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    
    // 取前8位作为激活码
    return [[hash substringToIndex:8] uppercaseString];
}

- (BOOL)isActivated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"is_activated"];
}

- (NSString *)getActivatedRedBookId {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"activated_redbook_id"];
}

@end 