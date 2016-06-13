//
//  MTCollectionScrollViewCell.m
//  MTUIKitDemo
//
//  Created by zj-db0519 on 16/6/12.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTCollectionScrollViewCell.h"

@implementation MTCollectionScrollViewCell
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.label.textAlignment = NSTextAlignmentCenter;
		self.label.font = [UIFont boldSystemFontOfSize:15.0];
		self.label.backgroundColor = [UIColor blueColor];
		self.label.textColor = [UIColor whiteColor];
		[self.contentView addSubview:self.label];;
		self.contentView.layer.borderWidth = 1.0f;
		
	}
	return self;
}

@end
