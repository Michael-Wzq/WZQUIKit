//
//  UIImage+MTUtils.m
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import "UIImage+MTUtils.h"

@implementation UIImage (MTUtils)

- (UIImage *)mt_transformImageToSize:(CGSize)size {
    
    // 创建一个bitmap的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return image;
}

- (UIImage *)mt_resizableImageWithCapInsets:(UIEdgeInsets)insets {
    
    return  [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)mt_imageWithColor:(UIColor *)color size:(CGSize)size
{
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
    
}
@end
