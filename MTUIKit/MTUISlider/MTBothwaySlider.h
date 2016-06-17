//
//  MTBothwaySlider.h
//  PhotoControlDemo
//
//  Created by 李超前 on 16/4/20.
//  Copyright © 2016年 李超前. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTAdsorbInfo.h"

/**
 *  自定义的可左右滑动的Slider
 */
@interface MTBothwaySlider : UISlider

@property (nonatomic, strong) UIColor *blankColor;  //空白区域颜色(默认lightGrayColor)
@property (nonatomic, strong) UIColor *rangeColor;  //非空白区域的颜色(默认blueColor)
@property (nonatomic, assign) CGFloat baseValue;    //基准值(默认0.5，即为滑竿正中间)

@property (nonatomic, strong) MTAdsorbInfo *adsorbInfo; //吸附信息(含吸附区间及该区间要吸附到什么值)

@end
