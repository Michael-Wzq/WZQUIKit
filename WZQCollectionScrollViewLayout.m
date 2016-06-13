//
//  MTCollectionScrollViewLayout.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTCollectionScrollViewLayout.h"
#define ITEM_SIZE_WIDTH 50.0
#define ITEM_SIZE_HEGIHT 30.0
#define ITEMS_Spaceing  10
#define ACTIVE_DISTANCE 50 //放大有效长度
#define ZOOM_FACTOR 0.3    //放大因子
@implementation MTCollectionScrollViewLayout
-(id)initWithHeight:(CGFloat)height width:(CGFloat)width  contentWidth:(CGFloat)contentWidth
{
	self = [super init];
	if (self) {
		self.itemSize = CGSizeMake(width, height);
		//  水平滑动
		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		//  确定缩进
		self.sectionInset = UIEdgeInsetsMake(0, (contentWidth-width)/2, 0, (contentWidth-width)/2);
		//  每个item在水平方向的最小间距
		self.minimumLineSpacing = ITEMS_Spaceing;
		
	}
	return self;
}

//-(id)initWith
//{
//	self = [super init];
//	if (self) {
//		self.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_HEGIHT);
//		//  水平滑动
//		self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//		//  确定缩进
////		self.sectionInset = UIEdgeInsetsMake(0, (1-ZOOM_FACTOR)*ITEMS_Spaceing, 0, ITEMS_Spaceing*(1-ZOOM_FACTOR));
//		self.sectionInset = UIEdgeInsetsMake(0, 200, 0, 200);
//		//  每个item在水平方向的最小间距
//		self.minimumLineSpacing = ITEMS_Spaceing;
//		
//	}
//	return self;
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
	return YES;
}
//  初始的layout外观将由该方法返回的UICollctionViewLayoutAttributes来决定
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
	
	NSArray* array = [super layoutAttributesForElementsInRect:rect];
	CGRect visibleRect;
	visibleRect.origin = self.collectionView.contentOffset;
	visibleRect.size = self.collectionView.bounds.size;
	for (UICollectionViewLayoutAttributes* attributes in array) {
		if (CGRectIntersectsRect(attributes.frame, rect)) {
			CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
			CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
			if (ABS(distance) < ACTIVE_DISTANCE) {
				CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance));
				attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
				attributes.zIndex = 1;
			}
		}
	}
	return array;
}

//  自动对齐到网格
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
	//  proposedContentOffset是没有对齐到网格时本来应该停下来的位置
	CGFloat offsetAdjustment = MAXFLOAT;
	CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
	//  当前显示的区域
	CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
	//  取当前显示的item
	NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
	//  对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
	for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
		CGFloat itemHorizontalCenter = layoutAttributes.center.x;
		if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
			offsetAdjustment = itemHorizontalCenter - horizontalCenter;
		}
	}
	return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}



@end
