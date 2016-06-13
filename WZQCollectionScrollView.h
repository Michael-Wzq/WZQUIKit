//
//  MTCollectionScrollView.h
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MTCollectionScrollView : UICollectionView

@property (nonatomic, assign) NSInteger defaultIndex;               //控件显示默认选中的选项
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *titlesArray;



@end
