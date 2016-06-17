//
//  MTProgressHUD.m
//
//  Copyright 2011-2014 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/MTProgressHUD
//

#if !__has_feature(objc_arc)
#error MTProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

/**
 *  颜色宏定义
 */
#define RGB(r, g, b)        [UIColor colorWithRed: r / 255.f green: g / 255.f blue: b / 255.f alpha: 1.f]
#define RGBA(r, g, b, a)     [UIColor colorWithRed: r / 255.f green: g / 255.f blue: b / 255.f alpha: a]
#define RGBAHEX(hex, a)    RGBA((float)((hex & 0xFF0000) >> 16), (float)((hex & 0xFF00) >> 8), (float)(hex & 0xFF), a)


#import "MTProgressHUD.h"


#import <QuartzCore/QuartzCore.h>


NSString * const MTProgressHUDDidReceiveTouchEventNotification = @"MTProgressHUDDidReceiveTouchEventNotification";
NSString * const MTProgressHUDDidTouchDownInsideNotification = @"MTProgressHUDDidTouchDownInsideNotification";
NSString * const MTProgressHUDWillDisappearNotification = @"MTProgressHUDWillDisappearNotification";
NSString * const MTProgressHUDDidDisappearNotification = @"MTProgressHUDDidDisappearNotification";
NSString * const MTProgressHUDWillAppearNotification = @"MTProgressHUDWillAppearNotification";
NSString * const MTProgressHUDDidAppearNotification = @"MTProgressHUDDidAppearNotification";

NSString * const MTProgressHUDStatusUserInfoKey = @"MTProgressHUDStatusUserInfoKey";

static UIColor *MTProgressHUDBackgroundColor;
static UIColor *MTProgressHUDForegroundColor;
static CGFloat MTProgressHUDRingThickness;
static UIFont *MTProgressHUDFont;
static UIImage *MTProgressHUDInfoImage;
static UIImage *MTProgressHUDSuccessImage;
static UIImage *MTProgressHUDErrorImage;
static MTProgressHUDMaskType MTProgressHUDDefaultMaskType;

static const CGFloat MTProgressHUDRingRadius = 18;
//static const CGFloat MTProgressHUDRingNoTextRadius = 24;
static const CGFloat MTProgressHUDParallaxDepthPoints = 10;
static const CGFloat MTProgressHUDUndefinedProgress = -1;

@interface MTProgressHUD ()

@property (nonatomic, readwrite) MTProgressHUDMaskType maskType;
@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;
@property (nonatomic, readonly, getter = isClear) BOOL clear;

@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UILabel *stringLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *indefiniteAnimatedView;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;
@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, assign) UIOffset offsetFromCenter;
@property (nonatomic, assign) BOOL mtAlbumLoading;
@property (nonatomic, copy) void(^dismissHandler)();


- (void)showProgress:(float)progress status:(NSString*)string maskType:(MTProgressHUDMaskType)hudMaskType;
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration maskType:(MTProgressHUDMaskType)hudMaskType;

- (void)dismiss;

- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (NSDictionary *)notificationUserInfo;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;
- (NSTimeInterval)displayDurationForString:(NSString*)string;

@end


@implementation MTProgressHUD

+ (MTProgressHUD*)sharedView {
    static dispatch_once_t once;
    static MTProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}


#pragma mark - Setters

+ (void)setStatus:(NSString *)string {
	[[self sharedView] setStatus:string];
}

+ (void)setBackgroundColor:(UIColor *)color {
    [self sharedView].hudView.backgroundColor = color;
    MTProgressHUDBackgroundColor = color;
}

+ (void)setForegroundColor:(UIColor *)color {
    [self sharedView];
    MTProgressHUDForegroundColor = color;
}

+ (void)setFont:(UIFont *)font {
    [self sharedView];
    MTProgressHUDFont = font;
}

+ (void)setRingThickness:(CGFloat)width {
    [self sharedView];
    MTProgressHUDRingThickness = width;
}

+ (void)setInfoImage:(UIImage*)image{
    [self sharedView];
    MTProgressHUDInfoImage = image;
}

+ (void)setSuccessImage:(UIImage *)image {
    [self sharedView];
    MTProgressHUDSuccessImage = image;
}

+ (void)setErrorImage:(UIImage *)image {
    [self sharedView];
    MTProgressHUDErrorImage = image;
}

+ (void)setDefaultMaskType:(MTProgressHUDMaskType)maskType{
    [self sharedView];
    MTProgressHUDDefaultMaskType = maskType;
}


#pragma mark - Show Methods

+ (void)show {
    [self showWithStatus:nil];
}

+ (void)showWithMaskType:(MTProgressHUDMaskType)maskType {
    [self showProgress:MTProgressHUDUndefinedProgress maskType:maskType];
}

+ (void)showWithStatus:(NSString *)status {
    [self showProgress:MTProgressHUDUndefinedProgress status:status];
}

+ (void)showWithStatus:(NSString*)status maskType:(MTProgressHUDMaskType)maskType {
    [self showProgress:MTProgressHUDUndefinedProgress status:status maskType:maskType];
}

+ (void)showProgress:(float)progress {
    [self sharedView];
    [self showProgress:progress maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showProgress:(float)progress maskType:(MTProgressHUDMaskType)maskType{
    [self showProgress:progress status:nil maskType:maskType];
}

+ (void)showProgress:(float)progress status:(NSString *)status {
    [self showProgress:progress status:status maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showProgress:(float)progress status:(NSString *)status maskType:(MTProgressHUDMaskType)maskType {
    [self sharedView].mtAlbumLoading = NO;
    [[self sharedView] showProgress:progress status:status maskType:maskType];
}

+ (void)showMTAlbumLoadingWithMessage:(NSString *)msg
{
    [self sharedView].mtAlbumLoading = YES;
    [[self sharedView] showProgress:MTProgressHUDUndefinedProgress status:msg maskType:MTProgressHUDMaskTypeClear];
}


#pragma mark - Show then dismiss methods

+ (void)showInfoWithStatus:(NSString *)string {
    [self sharedView];
    [self showInfoWithStatus:string maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showInfoWithStatus:(NSString *)string maskType:(MTProgressHUDMaskType)maskType {
    [self sharedView];
    [self showImage:MTProgressHUDInfoImage status:string maskType:maskType];
}

+ (void)showSuccessWithStatus:(NSString *)string {
    [self sharedView];
    [self showSuccessWithStatus:string maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showSuccessWithStatus:(NSString *)string maskType:(MTProgressHUDMaskType)maskType {
    [self sharedView];
    [self showImage:MTProgressHUDSuccessImage status:string maskType:maskType];
}

+ (void)showErrorWithStatus:(NSString *)string {
    [self sharedView];
    [self showErrorWithStatus:string maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showErrorWithStatus:(NSString *)string maskType:(MTProgressHUDMaskType)maskType {
    [self sharedView];
    [self showImage:MTProgressHUDErrorImage status:string maskType:maskType];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string {
    [self sharedView];
    [self showImage:image status:string maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string maskType:(MTProgressHUDMaskType)maskType {
    NSTimeInterval displayInterval = [[self sharedView] displayDurationForString:string];
    [self sharedView].mtAlbumLoading = NO;
    [[self sharedView] showImage:image status:string duration:displayInterval maskType:maskType];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration {
    [self sharedView].mtAlbumLoading = NO;
    [[self sharedView] showImage:image status:string duration:duration maskType:MTProgressHUDDefaultMaskType];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration dismissHandler:(void(^)())dismissHandler
{
    [self sharedView].mtAlbumLoading = NO;
    [self sharedView].dismissHandler = dismissHandler;
    [[self sharedView] showImage:image status:string duration:duration maskType:MTProgressHUDDefaultMaskType];
}

#pragma mark - Dismiss Methods

+ (void)popActivity {
    if([self sharedView].activityCount > 0)
        [self sharedView].activityCount--;
    if([self sharedView].activityCount == 0)
        [[self sharedView] dismiss];
}

+ (void)dismissLoading
{
    if ([self sharedView].mtAlbumLoading) {
        [self dismiss];
    }
}

+ (void)dismiss {
    if ([self isVisible]) {
        [[self sharedView] dismiss];
    }
}


#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.0f;
        self.activityCount = 0;
        MTProgressHUDFont = [UIFont systemFontOfSize:16.0f];
//        MTProgressHUDBackgroundColor = [UIColor colorWithRed:38.f/255.f green:38.f/255.f blue:43.f/255.f alpha:0.9f];
        MTProgressHUDBackgroundColor = RGBAHEX(0x000000, 1.f);

        MTProgressHUDForegroundColor = [UIColor whiteColor];
        if ([[UIImage class] instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
            MTProgressHUDInfoImage = [[UIImage imageNamed:@"MTProgressHUD.bundle/info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            MTProgressHUDSuccessImage = [[UIImage imageNamed:@"MTProgressHUD.bundle/success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            MTProgressHUDErrorImage = [[UIImage imageNamed:@"MTProgressHUD.bundle/error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            MTProgressHUDInfoImage = [UIImage imageNamed:@"MTProgressHUD.bundle/info"];
            MTProgressHUDSuccessImage = [UIImage imageNamed:@"MTProgressHUD.bundle/success"];
            MTProgressHUDErrorImage = [UIImage imageNamed:@"MTProgressHUD.bundle/error"];
        }
        MTProgressHUDRingThickness = 2;
        MTProgressHUDDefaultMaskType = MTProgressHUDMaskTypeNone;
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
        case MTProgressHUDMaskTypeBlack: {
            
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            
            break;
        }
        case MTProgressHUDMaskTypeGradient: {
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGFloat freeHeight = CGRectGetHeight(self.bounds) - self.visibleKeyboardHeight;
            
            CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, freeHeight/2);
            float radius = MIN(CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds)) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
        default:
            break;
    }
}

- (void)updatePosition {
	
    CGFloat hudWidth = 100.0f;
    CGFloat hudHeight = 100.0f;
    CGFloat stringHeightBuffer = 20.0f;
    CGFloat stringAndContentHeightBuffer = 80.0f;
    
    CGFloat stringWidth = 0.0f;
    CGFloat stringHeight = 0.0f;
    CGRect labelRect = CGRectZero;
    
    NSString *string = self.stringLabel.text;
    
    // Check if an image or progress ring is displayed
    BOOL imageUsed = (self.imageView.image) || (self.imageView.hidden);
    BOOL progressUsed = (self.progress != MTProgressHUDUndefinedProgress) && (self.progress >= 0.0f);
    
    if(string) {
        CGSize constraintSize = CGSizeMake(220.0f, 300.0f);
        CGRect stringRect;
        if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
          stringRect = [string boundingRectWithSize:constraintSize
                                            options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                         attributes:@{NSFontAttributeName: self.stringLabel.font}
                                            context:NULL];
        } else {
            CGSize stringSize;
            
            if ([string respondsToSelector:@selector(sizeWithAttributes:)])
                stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.stringLabel.font.fontName size:self.stringLabel.font.pointSize]}];
            else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200.0f, 300.0f)];
#pragma clang diagnostic pop
            
            stringRect = CGRectMake(0.0f, 0.0f, stringSize.width, stringSize.height);
        }
        stringWidth = stringRect.size.width;
        stringHeight = ceil(CGRectGetHeight(stringRect));
        
        if (imageUsed || progressUsed)
            hudHeight = stringAndContentHeightBuffer + stringHeight;
        else
            hudHeight = stringHeightBuffer + stringHeight;
        
        if(stringWidth > hudWidth)
            hudWidth = ceil(stringWidth/2)*2;
        
        CGFloat labelRectY = (imageUsed || progressUsed) ? 68.0f : 9.0f;
        
        labelRect = CGRectMake(12.0f, labelRectY, hudWidth, stringHeight);
        hudWidth += 24.0f;
    }
	
    if (self.mtAlbumLoading) {
        hudWidth = 100.f;
        hudHeight = 88.f;
    }
    
	self.hudView.bounds = CGRectMake(0.0f, 0.0f, hudWidth, hudHeight);
    
    if(string)
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36.0f);
	else
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.frame = labelRect;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	if(string) {
        [self.indefiniteAnimatedView sizeToFit];
        
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36.0f);
        self.indefiniteAnimatedView.center = center;
        
        if(self.progress != MTProgressHUDUndefinedProgress)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36.0f);
	} else {
        [self.indefiniteAnimatedView sizeToFit];
        
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
        self.indefiniteAnimatedView.center = center;
        
        if(self.progress != MTProgressHUDUndefinedProgress)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
    }
    
    [CATransaction commit];
}

- (void)setStatus:(NSString *)string {
	self.stringLabel.text = string;
    [self updatePosition];
    
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    if(_fadeOutTimer)
        [_fadeOutTimer invalidate], _fadeOutTimer = nil;
    
    if(newTimer)
        _fadeOutTimer = newTimer;
}

- (void)setMtAlbumLoading:(BOOL)mtAlbumLoading
{
    _mtAlbumLoading = mtAlbumLoading;
    if (mtAlbumLoading) {
        MTProgressHUDBackgroundColor = RGBAHEX(0xffffff, 1.f);
        
        self.hudView.layer.shadowOffset = CGSizeMake(0,0);
        
        self.hudView.layer.shadowOpacity = .3f;
        
        self.hudView.layer.shadowRadius = 1.5f;
        
        self.hudView.layer.shadowColor = RGBAHEX(0x000000, 1.f).CGColor;
        
        self.hudView.layer.masksToBounds = NO;
        
    } else {
        self.hudView.layer.shadowOpacity = 0.f;

//        MTProgressHUDBackgroundColor = [UIColor colorWithRed:38.f/255.f green:38.f/255.f blue:43.f/255.f alpha:0.9f];
        MTProgressHUDBackgroundColor = RGBAHEX(0x000000, 1.f);
        self.hudView.layer.borderWidth = 0.f;
    }
    [MTProgressHUD sharedView].hudView.backgroundColor = MTProgressHUDBackgroundColor;
}

- (void)registerNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(positionHUD:)
//                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
//                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(positionHUD:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(positionHUD:)
//                                                 name:UIKeyboardDidHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(positionHUD:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(positionHUD:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}


- (NSDictionary *)notificationUserInfo{
    return (self.stringLabel.text ? @{MTProgressHUDStatusUserInfoKey : self.stringLabel.text} : nil);
}


- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;
    
    self.frame = UIScreen.mainScreen.bounds;
    
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    // no transforms applied to window in iOS 8, but only if compiled with iOS 8 sdk as base sdk, otherwise system supports old rotation logic.
    BOOL ignoreOrientation = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        ignoreOrientation = YES;
    }
#endif

    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(ignoreOrientation || UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            else
                keyboardHeight = CGRectGetWidth(keyboardFrame);
        }
    } else {
        keyboardHeight = 0.f;//不根据键盘高度调整
//        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = self.bounds;
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
    
    if(!ignoreOrientation && UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = CGRectGetWidth(orientationFrame);
        orientationFrame.size.width = CGRectGetHeight(orientationFrame);
        orientationFrame.size.height = temp;
        
        temp = CGRectGetWidth(statusBarFrame);
        statusBarFrame.size.width = CGRectGetHeight(statusBarFrame);
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    
    if(keyboardHeight > 0)
        activeHeight += CGRectGetHeight(statusBarFrame)*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = CGRectGetWidth(orientationFrame)/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    if (ignoreOrientation) {
        rotateAngle = 0.0;
        newCenter = CGPointMake(posX, posY);
    } else {
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateAngle = M_PI;
                newCenter = CGPointMake(posX, CGRectGetHeight(orientationFrame)-posY);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotateAngle = -M_PI/2.0f;
                newCenter = CGPointMake(posY, posX);
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotateAngle = M_PI/2.0f;
                newCenter = CGPointMake(CGRectGetHeight(orientationFrame)-posY, posX);
                break;
            default: // as UIInterfaceOrientationPortrait
                rotateAngle = 0.0;
                newCenter = CGPointMake(posX, posY);
                break;
        }
    }
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:NULL];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
        [self.hudView setNeedsDisplay];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
}

- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDDidReceiveTouchEventNotification object:event];
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.hudView.frame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDDidTouchDownInsideNotification object:event];
    }
}

- (void)willEnterForegroundNotification:(NSNotification *)notification
{
    // 从后台返回时，动画会停止。需重新启动
    if (_indefiniteAnimatedView.superview == self.hudView) {
        if (![_indefiniteAnimatedView isAnimating]) {
            [_indefiniteAnimatedView startAnimating];
        }
    }
}

#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)string maskType:(MTProgressHUDMaskType)hudMaskType {
    if(!self.overlayView.superview){
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        UIScreen *mainScreen = UIScreen.mainScreen;
        
        for (UIWindow *window in frontToBackWindows)
            if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
    } else {
        // Ensure that overlay will be exactly on top of rootViewController (which may be changed during runtime).
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    
    if(!self.superview)
        [self.overlayView addSubview:self];
    
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.maskType = hudMaskType;
    self.progress = progress;
    
    self.stringLabel.text = string;
    [self updatePosition];
    
    if(progress >= 0) {
        self.imageView.image = nil;
        self.imageView.hidden = NO;
        [self.indefiniteAnimatedView removeFromSuperview];
        [self.indefiniteAnimatedView stopAnimating];
        
        self.ringLayer.strokeEnd = progress;
        
        if(progress == 0)
            self.activityCount++;
    } else {
        self.activityCount++;
        [self cancelRingLayerAnimation];
        [self.hudView addSubview:self.indefiniteAnimatedView];
        [self.indefiniteAnimatedView startAnimating];
    }
    
    if(self.maskType != MTProgressHUDMaskTypeNone) {
        self.overlayView.userInteractionEnabled = YES;
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    } else {
        self.overlayView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }
    
    [self.overlayView setHidden:NO];
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self positionHUD:nil];
    
    if(self.alpha != 1 || self.hudView.alpha != 1) {
        NSDictionary *userInfo = [self notificationUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDWillAppearNotification
                                                            object:nil
                                                          userInfo:userInfo];
        
        [self registerNotifications];
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        if(self.isClear) {
            self.alpha = 1;
            self.hudView.alpha = 0;
        }
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             
                             if(self.isClear) // handle iOS 7 and 8 UIToolbar which not answers well to hierarchy opacity change
                                 self.hudView.alpha = 1;
                             else
                                 self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDDidAppearNotification
                                                                                 object:nil
                                                                               userInfo:userInfo];
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
                         }];
        
        [self setNeedsDisplay];
    }
}

- (UIImage *)image:(UIImage *)image withTintColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

- (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration maskType:(MTProgressHUDMaskType)hudMaskType {
    self.progress = MTProgressHUDUndefinedProgress;
    [self cancelRingLayerAnimation];
    
    if(![self.class isVisible])
        [self.class show];
//    if ([self isClear]) {
//        se
//    }
//    if ([self.imageView respondsToSelector:@selector(setTintColor:)]) {
//        self.imageView.tintColor = MTProgressHUDForegroundColor;
//    } else {
    if (image) {
        image = [self image:image withTintColor:MTProgressHUDForegroundColor];
    }
//    }
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.maskType = hudMaskType;
  
    self.stringLabel.text = string;
    [self updatePosition];
    [self.indefiniteAnimatedView removeFromSuperview];
    [self.indefiniteAnimatedView stopAnimating];
    
    if(self.maskType != MTProgressHUDMaskTypeNone) {
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    } else {
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
    
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}

- (void)dismiss {
    NSDictionary *userInfo = [self notificationUserInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDWillDisappearNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
    __block BOOL mtAlbumLoading = self.mtAlbumLoading;
    self.activityCount = 0;
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8f, 0.8f);
                         if(self.isClear) // handle iOS 7 UIToolbar not answer well to hierarchy opacity change
                             self.hudView.alpha = 0.0f;
                         else
                             self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if (self.dismissHandler && !mtAlbumLoading) {
                             self.dismissHandler();
                             self.dismissHandler = nil;
                         }
                         
                         if(self.alpha == 0.0f || self.hudView.alpha == 0.0f) {
                             self.alpha = 0.0f;
                             self.hudView.alpha = 0.0f;
                             
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                             [self cancelRingLayerAnimation];
                             [_hudView removeFromSuperview];
                             _hudView = nil;
                             
                             [_overlayView removeFromSuperview];
                             _overlayView = nil;
                             
                             [_indefiniteAnimatedView removeFromSuperview];
                             [_indefiniteAnimatedView stopAnimating];
                             _indefiniteAnimatedView = nil;
                             
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:MTProgressHUDDidDisappearNotification
                                                                                 object:nil
                                                                               userInfo:userInfo];
                             
                             // Tell the rootViewController to update the StatusBar appearance
                             UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                             if ([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                                 [rootController setNeedsStatusBarAppearanceUpdate];
                             }
                             // uncomment to make sure UIWindow is gone from app.windows
                             //NSLog(@"%@", [UIApplication sharedApplication].windows);
                             //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                         }
                     }];
}


#pragma mark - Ring progress animation
// TODO: 暂时没用，需要跑马灯效果时加入图片资源，再恢复for{}里边的注释代码
- (UIImageView *)indefiniteAnimatedView {
    if (_indefiniteAnimatedView == nil) {
        // 加载动画图片
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:18];
        for (int i = 0; i < 40; i++) {
            NSString *imageName = [NSString stringWithFormat:@"mt_cloudalbum_cloud_shape_loading%d", i];
            UIImage *image = [UIImage imageNamed:imageName];
            [imageArray addObject:image];
        }
        // 设置动画
        _indefiniteAnimatedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _indefiniteAnimatedView.animationImages = imageArray;
        _indefiniteAnimatedView.animationDuration = 2.f;
        _indefiniteAnimatedView.animationRepeatCount = NSIntegerMax;
        [_indefiniteAnimatedView sizeToFit];
    }
    return _indefiniteAnimatedView;
}

- (CAShapeLayer *)ringLayer {
    if(!_ringLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center
                                              radius:MTProgressHUDRingRadius
                                           lineWidth:MTProgressHUDRingThickness
                                               color:MTProgressHUDForegroundColor];
        [self.hudView.layer addSublayer:_ringLayer];
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer {
    if(!_backgroundRingLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center
                                                        radius:MTProgressHUDRingRadius
                                                     lineWidth:MTProgressHUDRingThickness
                                                         color:[MTProgressHUDForegroundColor colorWithAlphaComponent:0.1f]];
        _backgroundRingLayer.strokeEnd = 1;
        [self.hudView.layer addSublayer:_backgroundRingLayer];
    }
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_hudView.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    
    UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineCapRound;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    
    return slice;
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([self sharedView].alpha == 1 && [self sharedView].hudView.alpha == 1);
}


#pragma mark - Getters

- (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MIN((float)string.length*0.06 + 0.5, 5.0);
}

- (BOOL)isClear { // used for iOS 7 and above
    return (self.maskType == MTProgressHUDMaskTypeClear || self.maskType == MTProgressHUDMaskTypeNone);
}

- (UIControl *)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        [_overlayView addTarget:self action:@selector(overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return _overlayView;
}

- (UIView *)hudView {
    if(!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.backgroundColor = MTProgressHUDBackgroundColor;
        _hudView.layer.cornerRadius = 2.f;
        _hudView.layer.masksToBounds = YES;

        _hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);

        if ([_hudView respondsToSelector:@selector(addMotionEffect:)]) {
            UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.x" type: UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            effectX.minimumRelativeValue = @(-MTProgressHUDParallaxDepthPoints);
            effectX.maximumRelativeValue = @(MTProgressHUDParallaxDepthPoints);

            UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y" type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            effectY.minimumRelativeValue = @(-MTProgressHUDParallaxDepthPoints);
            effectY.maximumRelativeValue = @(MTProgressHUDParallaxDepthPoints);

            UIMotionEffectGroup *effectGroup = [[UIMotionEffectGroup alloc] init];
            effectGroup.motionEffects = @[effectX, effectY];
            [_hudView addMotionEffect:effectGroup];
        }
    }
    
    if(!_hudView.superview)
        [self addSubview:_hudView];
    
    return _hudView;
}

- (UILabel *)stringLabel {
    if (!_stringLabel) {
        _stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_stringLabel.backgroundColor = [UIColor clearColor];
		_stringLabel.adjustsFontSizeToFitWidth = YES;
        _stringLabel.textAlignment = NSTextAlignmentCenter;
		_stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _stringLabel.numberOfLines = 0;
    }
    
    if(!_stringLabel.superview)
        [self.hudView addSubview:_stringLabel];

    _stringLabel.textColor = MTProgressHUDForegroundColor;
    _stringLabel.font = MTProgressHUDFont;
    
    return _stringLabel;
}

- (UIImageView *)imageView {
    if (!_imageView)
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    
    if(!_imageView.superview)
        [self.hudView addSubview:_imageView];
    
    return _imageView;
}


- (CGFloat)visibleKeyboardHeight {
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if ([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]) {
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if ([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]) {
            for (__strong UIView *possibleKeyboardSubview in [possibleKeyboard subviews]) {
                if ([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
    
    return 0;
}

@end

