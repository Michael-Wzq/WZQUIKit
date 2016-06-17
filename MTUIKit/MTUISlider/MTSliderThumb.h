//
//  MTSliderThumb.h
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTSliderThumb : UIButton


@property (nonatomic, strong) UIImage *normalImage;

@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, assign, setter=setThumbStatus:) BOOL isNormal;
@end
