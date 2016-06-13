//
//  MTCollectionScrollViewController.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTCollectionScrollViewController.h"
#import "MTUIKit.h"
#import "MTCollectionScrollView.h"

@interface MTCollectionScrollViewController ()

@end


@implementation MTCollectionScrollViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	MTCollectionScrollViewLayout *itemsLayout = [[MTCollectionScrollViewLayout alloc]initWithHeight:30 width:60  contentWidth:self.view.frame.size.width];
	MTCollectionScrollView *view = [[MTCollectionScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)
															collectionViewLayout:itemsLayout];
	NSArray *array = [[NSArray alloc] initWithObjects:@"特效",@"美颜",@"美妆",@"梦幻",nil];
	view.titlesArray = array;
	[self.view addSubview:view];
	
}


@end
