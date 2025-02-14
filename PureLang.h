#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TranslateSource) {
    TranslateSourceSystem = 0,
    TranslateSourceYoudao = 1,
    TranslateSourceBaidu = 2,
    TranslateSourceMicrosoft = 3
};

@interface PureLang : NSObject

+ (BOOL)isChineseText:(NSString *)text;
+ (BOOL)isEnglishText:(NSString *)text;
+ (NSString *)translateText:(NSString *)text;
+ (NSArray *)extractSpecialMarks:(NSString *)text cleanedText:(NSString **)cleanedText;

@end 