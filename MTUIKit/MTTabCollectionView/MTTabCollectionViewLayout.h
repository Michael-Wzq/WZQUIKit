//
//  MTCollectionScrollViewLayout.h
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTabCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat zoomFactor;      //  放大系数 默认0.3

/**
 *  初始化CollectionViewFlowLayout(固定滑动一格)
 *
 *  @param height cell高度
 *  @param width  cell宽度
 *  @param contentWidth collectionView的宽度
 *  @param itemsSpacing cell间距
 *
 *  @return MTCollectionScroll
 */
- (instancetype)initWithHeight:(CGFloat)height
						 width:(CGFloat)width
				  contentWidth:(CGFloat)contentWidth
				  itemsSpacing:(CGFloat)itemsSpacing;

@end
