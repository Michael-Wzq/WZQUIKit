//
//  MTCollectionScrollView.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTCollectionScrollView.h"
#import "MTCollectionScrollViewCell.h"
@interface MTCollectionScrollView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
	NSIndexPath *selectedIndexPath;
}



@end

@implementation MTCollectionScrollView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
	if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
		[self initUI];
		[self initData];
		
		
	}
	return self;
}




- (void)initUI {
	
	
	if (!self.defaultIndex) {
		self.defaultIndex = 1 ;
		
		
	}
	
	
	
}



- (void)initData {
	self.bounces = NO;
	self.delegate = self;
	self.dataSource = self;
	[self registerClass:[MTCollectionScrollViewCell class] forCellWithReuseIdentifier:@"MTTabCollectionViewCell"];
	selectedIndexPath = [NSIndexPath indexPathForRow:self.defaultIndex inSection:0];
	
	

}



#pragma UICollectionViewMethod

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	MTCollectionScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTTabCollectionViewCell" forIndexPath:indexPath];
	
	
//	NSIndexPath *selectedCellIndexPath = [self indexPathForItemAtPoint:CGPointMake(self.contentOffset.x + self.bounds.size.width/2, self.bounds.size.height/2)];
//	NSLog(@"%@",selectedCellIndexPath);
	//MTCollectionScrollViewCell *selectedCell = (MTCollectionScrollViewCell *)[self  cellForItemAtIndexPath:selectedCellIndexPath];

	cell.label.text = [NSString stringWithFormat:@"%@",_titlesArray[indexPath.row]];
	NSLog(@"%@",cell.label.text);
	if ([selectedIndexPath isEqual:indexPath]) {
		
	   cell.label.textColor = [UIColor greenColor];
			[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		
		
	} else {
	
		cell.label.textColor = [UIColor whiteColor];
	}
	
	

	
	
	
	return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.titlesArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
	[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
	selectedIndexPath = indexPath;
//	MTCollectionScrollViewCell *cell = (MTCollectionScrollViewCell *)[self  cellForItemAtIndexPath:indexPath];
//	cell.label.textColor = [UIColor greenColor];
	
	[self reloadData];
}

//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//	MTCollectionScrollViewCell *cell = (MTCollectionScrollViewCell *)[self  cellForItemAtIndexPath:indexPath];
//	cell.label.textColor = [UIColor whiteColor];
//	cell.selected=NO;
//	
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	selectedIndexPath = [self indexPathForItemAtPoint:CGPointMake(self.contentOffset.x + self.bounds.size.width/2, self.bounds.size.height/2)];
	NSLog(@"%@",selectedIndexPath);
	[self reloadData];
	
	
}


@end
