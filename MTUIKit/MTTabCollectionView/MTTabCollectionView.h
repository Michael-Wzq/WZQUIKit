//
//  MTTabCollectionView.h
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTTabCollectionView;
//  滑动以及点击SelectedCell回调block
typedef void (^SelectedBlock)(MTTabCollectionView *tabCollectionView, NSIndexPath *selectedIndexPath);

@interface MTTabCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (nonatomic, strong) NSArray *titlesArray;                 //  数组名称
@property (nonatomic, strong) UIColor *normalColor;                 //  未选中按钮颜色,默认白色
@property (nonatomic, strong) UIColor *selectedColor;               //  选中按钮颜色,默认绿色
@property (nonatomic, strong) UIColor *pointColor;                  //  底部圆点颜色,默认绿色
@property (nonatomic, assign) CGFloat pointRadius;                  //  圆点半径大小,默认3
@property (nonatomic, copy) SelectedBlock selectedBlock;            //  回调block

/**
 *  创建TabCollectionView
 *
 *  @param frame TabCollectionView的frame
 *  @param layout 自定义MTTabCollectionLayout
 *  @param defaultIndex 默认位置
 *  @param selectedBlock 滑动或者点击事件的回调
 *  
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame
		 collectionViewLayout:(UICollectionViewLayout *)layout
				 defaultIndex:(NSInteger)defalutIndex
				selectedBlock:(SelectedBlock)selectedBlock;

@end
