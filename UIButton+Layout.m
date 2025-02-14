#import "UIButton+Layout.h"

@implementation UIButton (Layout)

- (void)centerImageAndTitle:(CGFloat)spacing {
    // 让图标和文字垂直居中对齐
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // 计算整体内容高度
    CGFloat totalHeight = imageSize.height + spacing + titleSize.height;
    CGFloat centerY = (self.frame.size.height - totalHeight) / 2;
    
    // 设置图标位置
    self.imageView.frame = CGRectMake((self.frame.size.width - imageSize.width) / 2,
                                     centerY,
                                     imageSize.width,
                                     imageSize.height);
    
    // 设置文字位置
    self.titleLabel.frame = CGRectMake((self.frame.size.width - titleSize.width) / 2,
                                      centerY + imageSize.height + spacing,
                                      titleSize.width,
                                      titleSize.height);
}

@end 