//
//  MTAdsorbInfo.h
//  PhotoControlDemo
//
//  Created by 李超前 on 16/4/20.
//  Copyright © 2016年 李超前. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTAdsorbInfo : NSObject

@property (nonatomic, assign) CGFloat adsorbMin; //吸附区间的最小值
@property (nonatomic, assign) CGFloat adsorbMax; //吸附区间的最小值
@property (nonatomic, assign) CGFloat adsorbToValue; //吸附到什么值上

/**
 *  创建吸附区间信息
 *
 *  @param adsorbMin     吸附区间的最小值
 *  @param adsorbMax     吸附区间的最小值
 *  @param adsorbToValue 吸附到什么值上
 *
 *  @return 吸附区间信息
 */
- (instancetype)initWithMin:(CGFloat)adsorbMin max:(CGFloat)adsorbMax toValue:(CGFloat)adsorbToValue;

@end
