#ifndef AssetManager_h
#define AssetManager_h

#import <UIKit/UIKit.h>

@interface AssetManager : NSObject

+ (UIImage *)imageNamed:(NSString *)name;
+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type;
+ (NSURL *)urlForResource:(NSString *)name withExtension:(NSString *)extension;

@end

#endif /* AssetManager_h */ 