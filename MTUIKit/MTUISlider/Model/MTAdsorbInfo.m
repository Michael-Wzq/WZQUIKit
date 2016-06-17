//
//  MTAdsorbInfo.m
//  PhotoControlDemo
//
//  Created by 李超前 on 16/4/20.
//  Copyright © 2016年 李超前. All rights reserved.
//

#import "MTAdsorbInfo.h"

@implementation MTAdsorbInfo

/** 完整的描述请参见文件头部 */
- (instancetype)initWithMin:(CGFloat)adsorbMin max:(CGFloat)adsorbMax toValue:(CGFloat)adsorbToValue {
    self = [super init];
    if (self) {
        self.adsorbMin = adsorbMin;
        self.adsorbMax = adsorbMax;
        self.adsorbToValue = adsorbToValue;
    }
    return self;
}

@end
