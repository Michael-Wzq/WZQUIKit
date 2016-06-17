//
//  UIImage+MTUtils.h
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MTUtils)

/**
 *  获取固定size的图片
 *
 *  @param size 图片尺寸
 *
 *  @return 修改后的图片
 */
- (UIImage *)mt_transformImageToSize:(CGSize)size;


- (UIImage *)mt_resizableImageWithCapInsets:(UIEdgeInsets)insets;

/**
 *  根据颜色创建图片
 *
 *  @param color 图片颜色
 *  @param size  图片大小
 *
 *  @return 纯色的图片
 */
+ (UIImage *)mt_imageWithColor:(UIColor *)color size:(CGSize)size;
@end
