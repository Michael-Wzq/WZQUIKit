//
//  MTTabScrollViewController.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/2.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTTabScrollViewController.h"

#import "MTUIKit.h"

@interface MTTabScrollViewController ()

@end

@implementation MTTabScrollViewController



- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	// 输入按钮标题
	NSArray *titleArray = [NSArray arrayWithObjects:@"特效",@"美妆",@"梦幻",@"四", nil];
	MTTabScrollView *sliderView = [[MTTabScrollView alloc]initWithFrame:CGRectMake(0, 300, 320, 60)];
	sliderView.titlesArray = titleArray;
    sliderView.didSelectedBlock = ^(MTTabScrollView *optionSlider, NSInteger index){
        NSLog(@"点击了%ld", (long)index);
    };
	//按钮选项间距
	sliderView.optionMargin = 20;
	//没点击的按钮大小
	sliderView.fontSize = 15;
	//点击的按钮大小
	sliderView.selectedFontSize =20;
	//设置哪个默认按钮
	sliderView.defaultIndex = 1;
	//设置按钮颜色
	sliderView.normalColor = [UIColor whiteColor];
	//设置点击按钮的颜色
	sliderView.selectedColor = [UIColor greenColor];
	//设置圆点颜色
	sliderView.pointColor =  [UIColor greenColor];
	[self.view addSubview:sliderView];
	sliderView.backgroundColor = [UIColor blackColor];
	
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
