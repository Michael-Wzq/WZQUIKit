//
//  MTRangeSlider.h
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTRangeSlider;


@protocol MTRangeSliderDelegate <NSObject>

/**
 *  Slider的值改变后触发
 *
 *  @param slider   当前的slider控件
 *  @param minValue 选取的区间的最小值
 *  @param maxValue 选取的区间最大值
 */
- (void)rangeSlider:(MTRangeSlider *)slider didChangedMinValue:(CGFloat)minValue didChangedMaxValue:(CGFloat)maxValue;

@end

@interface MTRangeSlider : UIControl

@property (nonatomic, assign) CGFloat minValue; /**< 最小值 */

@property (nonatomic, assign) CGFloat maxValue; /**< 最大值 */

@property (nonatomic, weak) id<MTRangeSliderDelegate> delegate;

@end
