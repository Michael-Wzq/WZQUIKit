//
//  MTTabCollectionView.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTTabCollectionView.h"
#import "MTTabCollectionViewCell.h"

@interface MTTabCollectionView () {
	NSIndexPath *selectedIndexPath;                   //  选中cell的Path
	UIView __weak *pointView;                         //  设置圆点视图
}
@end

@implementation MTTabCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout  defaultIndex:(NSInteger)defaultIndex selectedBlock:(SelectedBlock)selectedBlock{
	if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
		//  第一次选中按钮的回调
		self.selectedBlock = selectedBlock;
	    selectedIndexPath = [NSIndexPath indexPathForRow:defaultIndex inSection:0];
	    if (self.selectedBlock) {
		__weak MTTabCollectionView *weakself = self;
		self.selectedBlock(weakself,selectedIndexPath);
	    }
		[self initDefaultValue];
		[self addPointView];
		self.decelerationRate = UIScrollViewDecelerationRateFast;
	}
	return self;
}

- (void)addPointView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2, 0, self.pointRadius*2, self.pointRadius*2)];
	view.backgroundColor = self.pointColor;
	view.layer.cornerRadius = self.pointRadius;
	view.layer.masksToBounds = YES;
	pointView = view;
	[self addSubview:pointView];
}

- (void)initDefaultValue {
	self.bounces = NO;
	self.delegate = self;
	self.dataSource = self;
	[self registerClass:[MTTabCollectionViewCell class] forCellWithReuseIdentifier:@"MTTabCollectionViewCell"];
	if (!_selectedColor) {
		_selectedColor = [UIColor greenColor];
	}
	if (!_normalColor) {
		_normalColor = [UIColor	whiteColor];
	}
	if (!_pointColor) {
		_pointColor = [UIColor greenColor];
	}
	if (_pointRadius == 0 || !_pointRadius) {
		_pointRadius = 3;
	}
}

#pragma mark -setMethods DefaultValue
- (void) setPointColor:(UIColor *)pointColor {
	_pointColor = pointColor;
	pointView.backgroundColor = _pointColor;
	
}

- (void)setPointRadius:(CGFloat)pointRadius {
	_pointRadius = pointRadius;
	CGRect frame = pointView.frame;
	frame.size.width = _pointRadius*2;
	frame.size.height = _pointRadius*2;
	pointView.frame = frame;
}

#pragma mark -MTTabCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.titlesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	MTTabCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTTabCollectionViewCell" forIndexPath:indexPath];
	cell.label.text = [NSString stringWithFormat:@"%@",_titlesArray[indexPath.row]];
	if (selectedIndexPath == indexPath) {
		[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		cell.label.textColor = self.selectedColor;
	} else {
		cell.label.textColor = self.normalColor;
	}
	return cell;
}

#pragma mark -MTTabCollectionViewDelegate
// 点击事件触发
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	if (selectedIndexPath != indexPath) {
		selectedIndexPath = indexPath;
		if (self.selectedBlock) {
			__weak MTTabCollectionView *weakself = self;
			self.selectedBlock(weakself,indexPath);
		}
		[self reloadData];
	} else {
		return;
	}
	dispatch_time_t popTime = DISPATCH_TIME_NOW;
	popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
	collectionView.userInteractionEnabled = NO;
	[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		collectionView.userInteractionEnabled = YES;
	});
	
}

//  使圆点保持在视图中点
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	CGRect frame = pointView.frame;
	frame.origin.x = self.contentOffset.x+self.bounds.size.width/2;
	pointView.frame = frame;
}

//  滑动事件触发
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	NSIndexPath *indexPath = [self indexPathForItemAtPoint:CGPointMake(self.contentOffset.x + self.bounds.size.width/2, self.bounds.size.height/2)];
	if (selectedIndexPath != indexPath) {
		selectedIndexPath = indexPath;
	if (self.selectedBlock) {
		__weak MTTabCollectionView *weakself = self;
		self.selectedBlock(weakself,selectedIndexPath);
	}
	[self reloadData];
	}
}




@end
