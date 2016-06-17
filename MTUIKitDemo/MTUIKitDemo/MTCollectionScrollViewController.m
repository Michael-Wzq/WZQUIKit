//
//  MTCollectionScrollViewController.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//
#import "MTUIKit.h"
#import "MTCollectionScrollViewController.h"
#import "MTTabCollectionView.h"

@interface MTCollectionScrollViewController ()

@end


@implementation MTCollectionScrollViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MTTabCollectionViewLayout *itemsLayout = [[MTTabCollectionViewLayout alloc]initWithHeight:30 width:60 contentWidth:self.view.frame.size.width itemsSpacing:10];
	itemsLayout.zoomFactor = 0.3;
	MTTabCollectionView *view = [[MTTabCollectionView alloc]
									initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)
						     collectionViewLayout:itemsLayout
									 defaultIndex:2
								    selectedBlock:^(MTTabCollectionView *tabCollectionView, NSIndexPath *selectedIndexPath){

										switch (selectedIndexPath.row) {
											case 0:
												NSLog(@"特效效果");
												break;
											case 1:
												NSLog(@"美颜效果");
												break;
											case 2:
												NSLog(@"美妆效果");
												break;
											case 3:
												NSLog(@"梦幻效果");
												break;
											default:
												break;
										}
								}];
//	view.pointColor = [UIColor grayColor];
//	view.normalColor = [UIColor blackColor];
//	view.selectedColor = [UIColor redColor];
//	view.pointRadius = 3 ;
	NSArray *array = [[NSArray alloc] initWithObjects:@"特效",@"美颜",@"美妆",@"梦幻",nil];
	view.titlesArray = array;
	[self.view addSubview:view];
	

}


@end
