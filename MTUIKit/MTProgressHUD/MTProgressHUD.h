//
//  MTProgressHUD.h
//
//  Copyright 2011-2014 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/MTProgressHUD
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

extern NSString * const MTProgressHUDDidReceiveTouchEventNotification;
extern NSString * const MTProgressHUDDidTouchDownInsideNotification;
extern NSString * const MTProgressHUDWillDisappearNotification;
extern NSString * const MTProgressHUDDidDisappearNotification;
extern NSString * const MTProgressHUDWillAppearNotification;
extern NSString * const MTProgressHUDDidAppearNotification;

extern NSString * const MTProgressHUDStatusUserInfoKey;

typedef NS_ENUM(NSUInteger, MTProgressHUDMaskType) {
    MTProgressHUDMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    MTProgressHUDMaskTypeClear,     // don't allow user interactions
    MTProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD
    MTProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient
};

@interface MTProgressHUD : UIView

#pragma mark - Customization

+ (void)setBackgroundColor:(UIColor*)color;                 // default is [UIColor whiteColor]
+ (void)setForegroundColor:(UIColor*)color;                 // default is [UIColor blackColor]
+ (void)setRingThickness:(CGFloat)width;                    // default is 4 pt
+ (void)setFont:(UIFont*)font;                              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setInfoImage:(UIImage*)image;                       // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(UIImage*)image;                    // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(UIImage*)image;                      // default is the bundled error image provided by Freepik
+ (void)setDefaultMaskType:(MTProgressHUDMaskType)maskType; // default is MTProgressHUDMaskTypeNone

#pragma mark - Show Methods

+ (void)show;
+ (void)showWithMaskType:(MTProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(MTProgressHUDMaskType)maskType;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress maskType:(MTProgressHUDMaskType)maskType;
+ (void)showProgress:(float)progress status:(NSString*)status;
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(MTProgressHUDMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD a little bit later
+ (void)showInfoWithStatus:(NSString *)string;
+ (void)showInfoWithStatus:(NSString *)string maskType:(MTProgressHUDMaskType)maskType;

+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString*)string maskType:(MTProgressHUDMaskType)maskType;

+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string maskType:(MTProgressHUDMaskType)maskType;

// use 28x28 white pngs
+ (void)showImage:(UIImage*)image status:(NSString*)status;
+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(MTProgressHUDMaskType)maskType;
+ (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration;

+ (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration dismissHandler:(void(^)())dismissHandler;


+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed
+ (void)dismiss;
+ (void)dismissLoading;
+ (BOOL)isVisible;

/**
 *  展示跑马灯loading
 *
 *  @param msg 文字
 */
+ (void)showMTAlbumLoadingWithMessage:(NSString *)msg;

@end

