//
//  MTSlider.h
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTSliderPopover.h"
#import "UIImage+MTUtils.h"

@class MTSlider;
/**
 *   弹出框显示内容的枚举类型
 */
typedef NS_ENUM(NSUInteger, MTSliderPopoverDispalyType) {
    
    MTSliderPopoverDispalyTypeNum,          /**< 纯数字显示 */
    MTSliderPopoverDispalyTypePercent,      /**< 百分比显示 */
};

@protocol MTSliderDelegate <NSObject>

/**
 *  slider拖动后处罚这个回调方法
 *
 *  @param slider 当前slider控件
 *  @param value  改变后的值
 */
- (void)slider:(MTSlider *)slider didDargToValue:(CGFloat)value;

@end

/**
 *  单向滑竿、popover支持百分比和纯数字显示
 */
@interface MTSlider : UIControl

@property (nonatomic, assign) CGFloat minValue; /**< 最小值 */

@property (nonatomic, assign) CGFloat maxValue; /**< 最大值 */

@property (nonatomic, assign) MTSliderPopoverDispalyType popoverType; /**< 弹出框的类型 */

@property (nonatomic, strong) UIColor *minimumTrackTintColor; /**< 最小值方向滑竿颜色值 */

@property (nonatomic, strong) UIColor *maximumTrackTintColor; /**< 最大值方向滑竿颜色值 */

@property (nonatomic, strong) UIImage *thumbImage; /**< 滑块图片,默认是橙色按钮 */

@property (nonatomic, weak) id<MTSliderDelegate> delegate;  

@property (nonatomic, assign, readonly) CGFloat currentValue;   /**< Slider的值 */

@property (nonatomic, assign) CGFloat baseValue; // 基准值(默认0)
@property (nonatomic, strong) UIImage *baseImage;// 基准图片,默认是橙色按钮(baseValue为0时无baseImage)
@property (nonatomic, assign) CGFloat lineThick; // 线条粗细

/**
 *  隐藏或显示文字
 *
 *  @param isHidden 是否隐藏
 */
- (void)hidePopover:(BOOL)isHidden;

@end

