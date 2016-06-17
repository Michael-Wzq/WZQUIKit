//
//  MTSlider.m
//  PhotoControlDemo
//
//  Created by meitu on 16/4/5.
//  Copyright © 2016年 hwc. All rights reserved.
//

#import "MTSlider.h"
#import "MTSliderThumb.h"

static CGFloat const kMTSliderLeftPadding                         = 10.0f;
static CGFloat const kMTSliderBackgroundImageViewHeight           = 15.0f;
static CGFloat const kMTSliderThumbSizeWidth                      = 30.0f;
static CGFloat const kMTSliderThumbSizeHeight                     = 30.0f;
static CGFloat const kMTSliderPopoverWidth                        = 30.0f;
static CGFloat const kMTSliderPopoverHeight                       = 32.0f;
static CGFloat const kMTSliderBackgroundViewCornerRadius          = 8.0f;
static NSTimeInterval const kMTSliderPopoverAnimationDuration     = 0.7f;
static NSTimeInterval const kMTSliderDidTapSlidAnimationDuration  = 0.3f;

@interface MTSlider ()

@property (nonatomic, assign) CGRect lastFrame;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *frontImageView;

@property (nonatomic, strong) UIImageView *baseImageView;

@property (nonatomic, strong) MTSliderThumb *thumb;

@property (nonatomic, strong) MTSliderPopover *popover;

@property (nonatomic, assign, readwrite) CGFloat currentValue;


@end

@implementation MTSlider

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _lineThick = kMTSliderBackgroundImageViewHeight;
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.frontImageView];
    [self addSubview:self.thumb];
    [self addSubview:self.popover];
}



- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.lastFrame, self.frame)) {
        return;
    }
    
    self.lastFrame = self.frame;
    
    CGFloat backgroundImageViewY = self.bounds.size.height / 2 - _lineThick / 2;
    CGFloat backgroundImageViewWidth = self.bounds.size.width - kMTSliderLeftPadding * 2;
    self.backgroundImageView.frame = CGRectMake(kMTSliderLeftPadding, backgroundImageViewY,backgroundImageViewWidth,_lineThick);
    
    //CGFloat thumbX = 0;
    CGFloat backX = CGRectGetMinX(self.backgroundImageView.frame);
    CGFloat backWidth = CGRectGetWidth(self.backgroundImageView.bounds);
    CGFloat baseCenterX = backX + _baseValue * backWidth;
    
    CGFloat baseImageViewWidth = self.backgroundImageView.frame.size.height + 10;
    self.baseImageView.frame = CGRectMake(0, 0, baseImageViewWidth, baseImageViewWidth);
    self.baseImageView.center = CGPointMake(baseCenterX, CGRectGetHeight(self.frame)/2);
    
    CGFloat thumbWidth = kMTSliderThumbSizeWidth;
    CGFloat thumbX = baseCenterX - thumbWidth/2;
    CGFloat thumbY = self.bounds.size.height / 2 - kMTSliderThumbSizeHeight / 2;
    self.thumb.frame = CGRectMake(thumbX, thumbY, kMTSliderThumbSizeWidth, kMTSliderThumbSizeHeight);
    
    CGFloat popoverY = self.thumb.frame.origin.y - kMTSliderPopoverHeight;
    self.popover.frame = CGRectMake(0, popoverY, kMTSliderPopoverWidth, kMTSliderPopoverHeight);
    [self updateFrontImageView];
}


#pragma mark - Private

/**
 *  更新slider的进度
 */
- (void)updateFrontImageView {
    CGFloat backX = CGRectGetMinX(self.backgroundImageView.frame);
    CGFloat backY = CGRectGetMinY(self.backgroundImageView.frame);
    CGFloat backWidth = CGRectGetWidth(self.backgroundImageView.bounds);
    CGFloat backHeight = CGRectGetHeight(self.backgroundImageView.bounds);
    
    CGFloat frontY = backY;
    CGFloat frontHeight = backHeight;
    /*
    CGFloat frontX = backX;
    CGFloat frontWidth = CGRectGetMaxX(self.thumb.frame) - backX * 2;
    */
    
    CGFloat baseCenterX = backX + _baseValue * backWidth;
    
    CGFloat thumbX = CGRectGetMinX(self.thumb.frame);
    CGFloat thumbWidth = CGRectGetWidth(self.thumb.frame);
    CGFloat frontX = thumbX + thumbWidth/2;
    CGFloat frontWidth = baseCenterX - frontX;
    NSLog(@"thumbWidth = %f, frontWidth = %f", thumbWidth, frontWidth);
    
    CGRect frontImageViewFrame = CGRectMake(frontX, frontY, frontWidth, frontHeight);
    self.frontImageView.frame = frontImageViewFrame;
}


/**
 *  更新popover显示
 */
- (void)updatePopover {
    
    NSString *popoverText = [self popoverText];
    _currentValue = [popoverText floatValue];
    [self.popover updatePopoverTextValue:popoverText];
    
    CGRect tempRect = self.popover.frame;
    tempRect.origin.x = self.thumb.frame.origin.x;
    self.popover.frame = tempRect;
    [self showPopoverAnimated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didDargToValue:)]) {
        
        [self.delegate slider:self didDargToValue:_currentValue];
    }
}

/**
 *  获取popover需要显示的内容
 *  
 *  @return 百分比或者数值
 */
- (NSString *)popoverText {
    
    CGFloat percent = self.thumb.frame.origin.x / (self.bounds.size.width - kMTSliderThumbSizeWidth);
    NSString *popoverText = @"";
    if (_popoverType == MTSliderPopoverDispalyTypePercent) {
        //百分比显示
        popoverText = [NSString stringWithFormat:@"%.1f%%",percent * 100];
        
    } else {
        
        popoverText = [NSString stringWithFormat:@"%.1f",percent * (_maxValue - _minValue)];
    }
    return popoverText;
}

- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:kMTSliderPopoverAnimationDuration animations:^{
            self.popover.alpha = 1.0;
        }];
    } else {
        self.popover.alpha = 1.0;
    }
}

- (void)hidePopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:kMTSliderPopoverAnimationDuration animations:^{
            self.popover.alpha = 0;
        }];
    } else {
        self.popover.alpha = 0;
    }
}


#pragma mark - Event
/** 完整的描述请参见文件头部 */
- (void)hidePopover:(BOOL)isHidden {
    self.popover.hidden = isHidden;
}

- (void)buttonDidDrag:(UIButton *)button withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint lastPoint = [touch previousLocationInView:self];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat buttonWidth = CGRectGetWidth(button.bounds);
    CGFloat buttonCenterY = button.center.y;
    
    /*
    CGFloat buttonCenterX = button.center.x;
    CGFloat newButtonCenterX = MIN(width - buttonWidth / 2,
                                   MAX(buttonWidth / 2, buttonCenterX + (point.x - lastPoint.x)));
     */
    CGFloat newButtonX = button.frame.origin.x + (point.x - lastPoint.x);
    if (newButtonX < 0) {
        newButtonX = 0;
    }
    if (newButtonX > width - buttonWidth) {
        newButtonX = width - buttonWidth;
    }
    CGFloat newButtonCenterX = newButtonX + buttonWidth / 2;
    CGFloat newButtonCenterY = buttonCenterY;
    
    button.center = CGPointMake(newButtonCenterX, newButtonCenterY);
    
    [self updateFrontImageView];
    [self updatePopover];
}


- (void)buttonEndDrag:(UIButton *)button {
    
    [self hidePopoverAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self];
    
    [UIView animateWithDuration:kMTSliderDidTapSlidAnimationDuration animations:^{
        self.thumb.center = CGPointMake(MIN(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.thumb.bounds) / 2,
                                            MAX(CGRectGetWidth(self.thumb.bounds) / 2,
                                                point.x)), self.thumb.center.y);
        [self updateFrontImageView];
    } completion:^(BOOL finished) {
    
        [self updatePopover];
        [self hidePopoverAnimated:YES];
    }];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self hidePopoverAnimated:YES];
}



#pragma mark - Getter and Setter
- (void)setBaseValue:(CGFloat)baseValue {
    _baseValue = baseValue;
    
    if (_baseValue) {
        [self insertSubview:self.baseImageView aboveSubview:self.frontImageView];
        [self hidePopover:YES];
    }
}

- (UIImageView *)baseImageView {
    if (!_baseImageView) {
        UIImage *baseImage = [UIImage imageNamed:@"slider_thumbImage"];
        _baseImageView = [[UIImageView alloc] initWithImage:baseImage];
    }
    return _baseImageView;
}

- (void)setBaseImage:(UIImage *)baseImage {
    [self.baseImageView setImage:baseImage];
}

- (void)setLineThick:(CGFloat)lineThick {
    _lineThick = lineThick;
}

-(UIImageView *)backgroundImageView {
    
    if (!_backgroundImageView) {
        
        UIImage *backgroundImage = [UIImage imageNamed:@"slider_maximum_trackimage"];
        UIEdgeInsets insets = UIEdgeInsetsMake(3, 7, 3, 7);
        backgroundImage = [backgroundImage mt_resizableImageWithCapInsets:insets];
        _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundImageView.layer.cornerRadius = kMTSliderBackgroundViewCornerRadius;
        _backgroundImageView.layer.masksToBounds = YES;
        _backgroundImageView.alpha = 0.5;
    }
    return _backgroundImageView;
}

-(UIImageView *)frontImageView {
    
    if (!_frontImageView) {
        
        UIImage *frontImageView = [UIImage imageNamed:@"slider_minimum_trackimage"];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 0, 5);
        frontImageView = [frontImageView mt_resizableImageWithCapInsets:insets];
        _frontImageView = [[UIImageView alloc] initWithImage:frontImageView];
        _frontImageView.layer.cornerRadius = kMTSliderBackgroundViewCornerRadius;
        _frontImageView.layer.masksToBounds = YES;
    }
    return _frontImageView;
}


-(MTSliderThumb *)thumb {
    
    if (!_thumb) {
        
        _thumb = [MTSliderThumb buttonWithType:UIButtonTypeCustom];
        UIImage *thumbImage = [UIImage imageNamed:@"slider_thumbImage"];
        thumbImage = [thumbImage mt_transformImageToSize:CGSizeMake(kMTSliderThumbSizeWidth, kMTSliderThumbSizeHeight)];
        [_thumb setImage:thumbImage forState:UIControlStateNormal];
        [_thumb addTarget:self
                   action:@selector(buttonDidDrag:withEvent:)
         forControlEvents:UIControlEventTouchDragInside];
        [_thumb addTarget:self action:@selector(buttonEndDrag:) forControlEvents:UIControlEventTouchUpInside |
         UIControlEventTouchUpOutside];
      
    }
    return _thumb;
}

- (MTSliderPopover *)popover {
    
    if (!_popover) {
        _popover = [[MTSliderPopover alloc] initWithFrame:CGRectMake(0, 0, kMTSliderPopoverWidth, kMTSliderPopoverHeight)];
        _popover.alpha = 0;
    }
    return _popover;
}

-(void)setThumbImage:(UIImage *)thumbImage {
    
    [self.thumb setImage:thumbImage forState:UIControlStateNormal];
}

-(void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    
    UIImage *image = [UIImage mt_imageWithColor:minimumTrackTintColor size:CGSizeMake(kMTSliderThumbSizeWidth, kMTSliderThumbSizeHeight)];
    self.backgroundImageView.image = image;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    
    UIImage *image = [UIImage mt_imageWithColor:maximumTrackTintColor size:CGSizeMake(kMTSliderThumbSizeWidth, kMTSliderThumbSizeHeight)];
    self.frontImageView.image = image;
}

@end

