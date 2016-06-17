//
//  MTTabScrollView.h
//  Changed by wzq on 16/6/2.


//  MTOptionSlider.h
//  HDTest
//
//  Created by zj-dt0086 on 15/10/21.
//  Copyright © 2015年 zj-dt0086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTTabScrollView;

typedef void (^DidSelectedBlock)(MTTabScrollView *optionSlider, NSInteger index);

@interface MTTabScrollView : UIView

@property (nonatomic, assign) NSInteger defaultIndex;               //控件显示默认选中的选项
@property (nonatomic, assign, readonly) NSInteger currentIndex;     //当前按钮索引值
@property (nonatomic, retain) NSArray *titlesArray;                 //所有控件的名称
@property (nonatomic, strong) UIColor *normalColor;                 //normal文字颜色
@property (nonatomic, strong) UIColor *selectedColor;               //selected文字颜色
@property (nonatomic, strong) UIColor *pointColor;                  //底部圆点颜色
@property (nonatomic, assign) NSInteger optionMargin;               //每个选项间间距
@property (nonatomic, assign) CGFloat fontSize;                     //显示字体大小
@property (nonatomic, assign) CGFloat selectedFontSize;              //选中字体大小
@property (nonatomic, assign) NSInteger pointRadius;                //底部圆点半径
@property (nonatomic, copy) DidSelectedBlock didSelectedBlock;


/**
 *  初始化一个按钮宽度自适应文字的实例
 *
 *  @param frame  设置MTTabScrollViewframe
 *  @param titles 按钮标题数组
 *
 *  @return
 */
-(instancetype)initWithFrame:(CGRect)frame ;

/**
 *  初始化一个按钮宽度为固定值的实例
 *
 *  @param frame       设置MTTabScrollViewframe
 *  @param buttonWidth 按钮的宽度
 *
 *  @return 
 */
-(instancetype)initWithFrame:(CGRect)frame withButtonWidth:(NSInteger)buttonWidth;



/**
 *  移动到对应的选项
 *
 *  @param index        选项的索引值
 *  @param hasAnimation 移动过程是否有动画
 *  @param need         是否需要回调
 */
//- (void)moveToButton:(NSInteger)index animation:(BOOL)hasAnimation needDidSelectedBlock:(BOOL)need;

/**
 *  添加手势动作
 *
 *  @param leftSwipeGestureRecognizer 左滑动手势
 *  @param rightSwipeGestureRecognizer 右滑动手势
 */
//- (void)addLeftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)leftSwipeGestureRecognizer
//          rightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)rightSwipeGestureRecognizer;

/**
 *  移除手势动作
 *
 */
//- (void)removeSwipeGestureRecognizer;

@end
