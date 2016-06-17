//
//  MTTabCollectionViewLayout.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTTabCollectionViewLayout.h"




@interface MTTabCollectionViewLayout () {
	CGFloat activeDistance;
}
@end
@implementation MTTabCollectionViewLayout
- (instancetype)initWithHeight:(CGFloat)height
						 width:(CGFloat)width
				  contentWidth:(CGFloat)contentWidth
				  itemsSpacing:(CGFloat)itemsSpacing {
	if (self = [super init]) {
		//  cell大小
		self.itemSize = CGSizeMake(width, height);
		//  水平滑动
		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		//  确定缩进使第一个cell在中间
		self.sectionInset = UIEdgeInsetsMake(0, (contentWidth-width)/2+1, 0, (contentWidth-width)/2+1);
		//  每个item在水平方向的最小间距
		self.minimumLineSpacing = itemsSpacing;
		//  放大系数 
		if (!_zoomFactor) {
			_zoomFactor = 0.3;
		}
		//  随着中心放大区域
		activeDistance = width;
	}
	return self;
}

//  边界改变时,重新布局CollectionView
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return YES;
}

//  CollectionViewCell距离中心放大,随着距离放大递减,attributes需要用copy值来计算
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *array = [NSMutableArray array];
	CGRect visibleRect;
	visibleRect.origin = self.collectionView.contentOffset;
	visibleRect.size = self.collectionView.bounds.size;
	for (UICollectionViewLayoutAttributes *attributes in [super layoutAttributesForElementsInRect:rect]) {
		UICollectionViewLayoutAttributes *copyAttributes = [attributes copy];
		if (CGRectIntersectsRect(copyAttributes.frame, rect)) {
			CGFloat distance = CGRectGetMidX(visibleRect) - copyAttributes.center.x;
			CGFloat normalizedDistance = distance / activeDistance;
			if (ABS(distance) < activeDistance) {
				CGFloat zoom = 1 + _zoomFactor * (1 - ABS(normalizedDistance));
				copyAttributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1);
				copyAttributes.zIndex = 1;
			}
		}
		[array addObject:copyAttributes];
	}
	return array;
}

//  自动对齐到中点
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
	//  offsetAdjustment需要调整的距离
	CGFloat offsetAdjustment = MAXFLOAT;
	//  可见视图的水平中点
	CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2);
	//  当前显示的区域
	CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
	//  取当前显示的item
	NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
	//  对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
	for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
		CGFloat itemHorizontalCenter = layoutAttributes.center.x;
		if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
			offsetAdjustment = itemHorizontalCenter - horizontalCenter;
		}
	}
	return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}



@end
