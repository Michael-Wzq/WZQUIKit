//
//  MTTabScrollView.m
//  Changed by wzq on 16/6/2.

//  HDTest
//
//  Created by zj-dt0086 on 15/10/21.
//  Copyright © 2015年 zj-dt0086. All rights reserved.
//   

#import "MTTabScrollView.h"

typedef NS_ENUM(NSInteger, OptionSliderType) {
    optionSliderTypeAutoButtonWidth = 0,       //按钮宽度适应文字
    optionSliderTypeConstButtonWidth = 1       //按钮宽度为固定值
};

@interface MTTabScrollView () {
    NSInteger _contentViewWidth;
}

@property (nonatomic, strong) UIButton *selectedButton;     //当前选中的button
@property (nonatomic, strong) UIView *contentView;          //存放buttons的UIView
@property (nonatomic, strong) UIView *pointView;            //圆点
@property (nonatomic, assign) OptionSliderType sliderType;  //控件的类型(宽度固定和宽度不固定)
@property (nonatomic, assign) NSInteger constButtonWidth;   //固定宽度的按钮宽度
@property (nonatomic, strong) NSArray *allButtonArray;      //存放所有按钮对象
@property (nonatomic, strong) NSArray *buttonsLeftMarginArray; //存放每个按钮相对contentView视图的左边距
@property (nonatomic, strong) NSArray *buttonsWidthArray;   //每个按钮的宽度
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidthConstraint; //内容框约束宽度
@property (nonatomic, strong) NSLayoutConstraint *contentViewLeftConstraint;  //内容框左边offset
@end

@implementation MTTabScrollView

#pragma mark -Init
-(instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_defaultIndex = 0;
		self.sliderType = optionSliderTypeAutoButtonWidth;
		[self setupUIs];
	}
	return self;
}
-(instancetype)initWithFrame:(CGRect)frame  withButtonWidth:(NSInteger)buttonWidth{
	if (self = [super initWithFrame:frame]) {
		_defaultIndex = 0;
		self.sliderType = optionSliderTypeConstButtonWidth;
		self.constButtonWidth = buttonWidth;
		[self setupUIs];
	}
	return self;
}

//- (void)awakeFromNib {
//    [self setupUIs];
//}

#pragma mark -UI设置
- (void)setupUIs {
    self.backgroundColor = [UIColor blackColor];
    self.layer.masksToBounds = YES;
    //添加小圆形
    [self createPointView];
	//添加按钮内容视图
	[self createContentView];
    //添加手势
    [self addSwipeGesture];
}

- (void)createContentView {
	_contentView = [[UIView alloc] init];
	_contentView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_contentView];
	_contentView.backgroundColor = [UIColor blueColor];
	//设置内容视图的布局
	NSLayoutConstraint *contraintLeft = [NSLayoutConstraint constraintWithItem:_contentView
																	 attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0f
																	  constant:self.frame.size.width/2];
	NSLayoutConstraint *contraintWidth = [NSLayoutConstraint constraintWithItem:_contentView
																	  attribute:NSLayoutAttributeWidth
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	  attribute:NSLayoutAttributeNotAnAttribute
																	 multiplier:1.0f
																	   constant:_contentViewWidth];
	NSLayoutConstraint *contraintTop = [NSLayoutConstraint constraintWithItem:_contentView
																	attribute:NSLayoutAttributeTop
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.pointView
																	attribute:NSLayoutAttributeBottom
																   multiplier:1.0f
																	 constant:0];
	NSLayoutConstraint *contraintBottom = [NSLayoutConstraint constraintWithItem:_contentView
																	   attribute:NSLayoutAttributeBottom
																	   relatedBy:NSLayoutRelationEqual
																		  toItem:self
																	   attribute:NSLayoutAttributeBottom
																	  multiplier:1.0f
																		constant:0];
	NSArray *contraintArray = [NSArray arrayWithObjects:contraintLeft,contraintWidth,contraintTop,contraintBottom, nil];
	[self addConstraints:contraintArray];
	self.contentViewWidthConstraint = contraintWidth;
	self.contentViewLeftConstraint = contraintLeft;
}



//添加底部圆圈
- (void)createPointView {
    _pointView = [[UIView alloc] init];
    if (!self.pointColor) {
        self.pointColor = [UIColor redColor];
    }
    _pointView.backgroundColor = self.pointColor;
    
    if (0 == self.pointRadius) {
        self.pointRadius = 3;
    }
    float radius = self.pointRadius;
    _pointView.layer.cornerRadius = radius;
    _pointView.layer.masksToBounds = YES;
	//手动约束时必须把整个属性设置为NO
	_pointView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_pointView];
    //设置圆点的布局
	NSLayoutConstraint *contraintTop = [NSLayoutConstraint constraintWithItem:_pointView
																	attribute:NSLayoutAttributeTop
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self
																	attribute:NSLayoutAttributeTop
																   multiplier:1.0f
																	 constant:2];
	NSLayoutConstraint *contraintWidth = [NSLayoutConstraint constraintWithItem:_pointView
																	  attribute:NSLayoutAttributeWidth
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	  attribute:NSLayoutAttributeNotAnAttribute
																	 multiplier:1.0f
																	   constant:radius*2];
	NSLayoutConstraint *contraintHeight = [NSLayoutConstraint constraintWithItem:_pointView
																	   attribute:NSLayoutAttributeHeight
																	   relatedBy:NSLayoutRelationEqual
																		  toItem:nil
																	   attribute:NSLayoutAttributeNotAnAttribute
																	  multiplier:1.0f
																		constant:radius*2];
	NSLayoutConstraint *contraintCenterX = [NSLayoutConstraint constraintWithItem:_pointView
																		attribute:NSLayoutAttributeCenterX
																		relatedBy:NSLayoutRelationEqual
																		   toItem:self
																		attribute:NSLayoutAttributeCenterX
																	   multiplier:1.0f
																		 constant:0];
	NSArray *contraintArray = [NSArray arrayWithObjects:contraintTop,contraintWidth,contraintHeight,contraintCenterX, nil];
	[self addConstraints:contraintArray];
}

/**
 *  创建按钮选项
 *
 *  @param title  按钮选项显示名称的字符串
 *  @param btnTag 按钮选项的标记值
 *  @param titlesLength 按钮选项的长度
 *  @param maxLeftOffset 按钮选项左端到self左端的距离
 */
- (UIButton *)createAutoButtonWithTitle:(NSString *)title
							 withBtnTag:(NSInteger)btnTag
					   withTitlesLength:(CGFloat)titlesLength
					  withMaxLeftOffset:(NSInteger)maxLeftOffset {
	//添加按钮
	UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	//字体颜色
	if (!self.normalColor) {
		_normalColor = [UIColor grayColor];
	}
	[optionButton setTitleColor:self.normalColor forState:UIControlStateNormal];
	if (!self.selectedColor) {
		_selectedColor = [UIColor greenColor];
	}
	[optionButton setTitleColor:self.selectedColor forState:UIControlStateSelected];
	
	//字体大小
	if (0 != self.fontSize) {
		optionButton.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
	}
	optionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	
	[optionButton addTarget:self
					 action:@selector(btnClick:)
		   forControlEvents:UIControlEventTouchUpInside];
	
	[optionButton setTitle:title forState:UIControlStateNormal];
	[optionButton setTitle:title forState:UIControlStateHighlighted];
	[optionButton setTag:btnTag];
	
	//设置按钮的布局
	optionButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:optionButton];
	NSLayoutConstraint *contraintLeft = [NSLayoutConstraint constraintWithItem:optionButton
																	 attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		toItem:_contentView
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0f
																	  constant:maxLeftOffset];
	NSLayoutConstraint *contraintWidth = [NSLayoutConstraint constraintWithItem:optionButton
																	  attribute:NSLayoutAttributeWidth
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	  attribute:NSLayoutAttributeNotAnAttribute
																	 multiplier:1.0f
																	   constant:titlesLength];
	NSLayoutConstraint *contraintTop = [NSLayoutConstraint constraintWithItem:optionButton
																	attribute:NSLayoutAttributeTop
																	relatedBy:NSLayoutRelationEqual
																	   toItem:_contentView
																	attribute:NSLayoutAttributeTop
																   multiplier:1.0f
																	 constant:0];
	NSLayoutConstraint *contraintBottom = [NSLayoutConstraint constraintWithItem:optionButton
																	   attribute:NSLayoutAttributeBottom
																	   relatedBy:NSLayoutRelationEqual
																		  toItem:_contentView
																	   attribute:NSLayoutAttributeBottom
																	  multiplier:1.0f
																		constant:0];
	NSArray *contraintArray = [NSArray arrayWithObjects:contraintLeft,contraintWidth,contraintTop,contraintBottom, nil];
	[_contentView addConstraints:contraintArray];
	
	return optionButton;
}

/**
 *  将每个按钮选项添加入视图
 *
 *  @param titles 包含所有选项显示名称的数组
 */
- (void)addAutoButton:(NSArray *)titles {
    if (!titles || 0 == titles.count) {
        return;
    }
	
    if (0 == _optionMargin) {
        _optionMargin = 10;
    }
    
    NSInteger arrayCount = titles.count;
    //数组存放给个按钮的宽度
    NSMutableArray *buttonsWidth = [NSMutableArray arrayWithCapacity:arrayCount];
    //数组存放每个按钮的中心相对view左边距离
    NSMutableArray *buttonsLeftOffset = [NSMutableArray arrayWithCapacity:arrayCount];
    //数组存放所有的按钮
    NSMutableArray *mAllButtonArray = [NSMutableArray arrayWithCapacity:arrayCount];
    //存放当前插入的按钮距离父视图左边距
    NSInteger maxLeftOffset = 0;
    //按钮标示，也是之后的索引值
    NSInteger btnTag = 0;
	
    for (NSString *title in titles) {
        //计算按钮的宽度
        CGFloat titlesLength = 0;
        if (optionSliderTypeAutoButtonWidth == self.sliderType) {
            titlesLength = [self widthForTitle:title];
        }
        else if (optionSliderTypeConstButtonWidth == self.sliderType) {
            titlesLength = self.constButtonWidth;
        }
        
        [buttonsWidth addObject:[NSNumber numberWithFloat:titlesLength]];
        [buttonsLeftOffset addObject:[NSNumber numberWithFloat:maxLeftOffset]];
		
		//创建按钮并添加约束
		UIButton *optionButton = [self createAutoButtonWithTitle:title
													  withBtnTag:btnTag
												withTitlesLength:titlesLength
											   withMaxLeftOffset:maxLeftOffset];
		btnTag++;
		
        //button添加入allButtonArray
        [mAllButtonArray addObject:optionButton];
        
        //添加完按钮后再计算左边距
        if (0 == self.optionMargin) {
            self.optionMargin = 10;
        }
        maxLeftOffset += (titlesLength + self.optionMargin);
    }
    
    self.buttonsLeftMarginArray = buttonsLeftOffset;
    self.buttonsWidthArray = buttonsWidth;
    self.allButtonArray = mAllButtonArray;
	
	//添加完按钮后contentView宽度更新
    _contentViewWidth = maxLeftOffset - _optionMargin;
	//添加按钮后重新布局
	self.contentViewWidthConstraint.constant = _contentViewWidth;
	[_contentView setNeedsLayout];
	[_contentView layoutIfNeeded];
	
    if (0 < self.defaultIndex) {
        [self moveToButton:self.defaultIndex animation:NO needDidSelectedBlock:YES];
    }
	
}

#pragma mark -Setter methods
- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [self setButtonTitleColor:normalColor forState:UIControlStateNormal];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self setButtonTitleColor:selectedColor forState:UIControlStateSelected];
}

- (void)setPointColor:(UIColor *)pointColor {
    _pointColor = pointColor;
	_pointView.backgroundColor = self.pointColor;
}

- (void)setSelectedFontSize:(CGFloat)selectedFontSize {
	_selectedFontSize = selectedFontSize;
}

//设置默认首选项
- (void)setDefaultIndex:(NSInteger)defaultIndex {
    _defaultIndex = defaultIndex;
    //移动contentView到对应位置
    [self moveToButton:defaultIndex animation:NO needDidSelectedBlock:YES];
}

- (void)setOptionMargin:(NSInteger)optionMargin {
    _optionMargin = optionMargin;
    //刷新setTitlesArray
    [self setTitlesArray:_titlesArray];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self setTitlesArray:_titlesArray];
}

- (void)setTitlesArray:(NSArray *)titlesArray {
	_titlesArray = titlesArray;
    
    //添加按钮之前先清空之前的按钮
    [self removeAllSubViews:self.contentView];
    [self addAutoButton:titlesArray];
}

/**
 *  移除UIView的所有子视图
 *
 *  @param view 需要移除子视图的UIView
 */
- (void)removeAllSubViews:(UIView *)view {
    if (view.subviews.count) {
        for (UIView *subView in view.subviews) {
            [subView removeFromSuperview];
        }
    }
}

/**
 *  设置指定状态下按钮文字颜色
 *
 *  @param color 文字样色
 *  @param state 控件状态
 */
- (void)setButtonTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (self.contentView) {
        for (UIView *subView in self.contentView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                [((UIButton *)subView) setTitleColor:color forState:state];
            }
        }
    }
}

/**
 *  视图增加左右滑动手势
 *
 *  @return 带有左右滑动手势识别的视图
 */
- (void)addSwipeGesture {
    //左滑手势
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(swipeHandle:)];
	[gestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:gestureLeft];
    
    //右滑手势
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(swipeHandle:)];
    [gestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:gestureRight];
}

#pragma mark -手势代码
/**
 * 判断左右滑动
 * 
 * @param swipe 滑动手势
 */
- (void)swipeHandle:(UISwipeGestureRecognizer *)swipe {
    if (UISwipeGestureRecognizerDirectionLeft == swipe.direction) {
		//NSLog(@"left");
        //索引+1
        NSInteger changedIndex = self.selectedButton.tag + 1;
        NSInteger count = self.titlesArray.count;
        if (changedIndex - count >= 0) {
            return;
        }
        [self moveToButton:changedIndex animation:YES needDidSelectedBlock:YES];
    }
    else if (UISwipeGestureRecognizerDirectionRight == swipe.direction) {
        //NSLog(@"right");
        //索引-1
        NSInteger changedIndex = self.selectedButton.tag - 1;
        if (changedIndex < 0) {
            return;
        }
        [self moveToButton:changedIndex animation:YES needDidSelectedBlock:YES];
    }
}

/**
 *  移动到选中的按钮
 *
 *  @param changeIndex 选中按钮的索引值
 */
- (void)swipeButtonWithChange:(NSInteger)changeIndex {
    [self moveToButton:(self.selectedButton.tag + changeIndex) animation:YES needDidSelectedBlock:YES];
}

#pragma mark -Button click method
- (void)btnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.selectedButton) {
        if ([self.selectedButton isEqual:btn]) {
            return;
        }
    }
    //设置contentView的位置移动
    [self moveToButton:btn.tag animation:YES needDidSelectedBlock:YES];
}

/**
 * 移动按钮完距左边距离重新约束
 *
 * @param moveLength 移动距离
 */
- (void)refreshContentViewContraintsWithMoveLength:(CGFloat)moveLength {
	self.contentViewLeftConstraint.constant = moveLength;
	[_contentView setNeedsLayout];
}

/**
 * 移动到指定button
 *
 * @param index 要移动的按钮序号
 * @param index 要移动的按钮序号
 * @param index 要移动的按钮序号
 */
- (void)moveToButton:(NSInteger)index animation:(BOOL)hasAnimation needDidSelectedBlock:(BOOL)need{
    _currentIndex = index;
    //得到目标button相对contentView左边距的距离
    CGFloat leftMargin = [self.buttonsLeftMarginArray[index] floatValue];
    //目标按钮的宽度
	CGFloat buttonWidth = [self.buttonsWidthArray[index] floatValue];
    //移动距离
    CGFloat moveLength = (leftMargin + buttonWidth/2);
    //移动到目标button
    UIButton *toButton = (UIButton *)self.allButtonArray[index];
	
    //动画
    [UIView animateWithDuration:0.5f
					 animations:^{
						 //移动后重新约束
						 [self refreshContentViewContraintsWithMoveLength:-moveLength+self.frame.size.width/2];
						 if (hasAnimation) {
							 [_contentView layoutIfNeeded];
						 }
						
					 }
                     completion:^(BOOL finished) {
			             //移动后字体大小改变
                         self.selectedButton.selected = NO;
						 self.selectedButton.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
						 toButton.selected = YES;
						 toButton.titleLabel.font = [UIFont systemFontOfSize:self.selectedFontSize];
						 self.selectedButton = toButton;
		
						 if (need == YES) {
							  //block方法
							 if (self.didSelectedBlock) {
								 __weak MTTabScrollView *weakself = self;
								 self.didSelectedBlock(weakself, toButton.tag);
							 }
						 }
                     }];
}

#pragma mark -Other methods
/**
 *  计算字符串的宽度
 *
 *  @param title 要计算宽度的字符串
 *
 *  @return 字符串的宽度
 */
- (CGFloat)widthForTitle:(NSString *)title {
    if (0 == self.fontSize) {
        _fontSize =15;
    }
    return [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]}].width+10;
}

/**
 *  添加左右手势
 */
- (void)addLeftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)leftSwipeGestureRecognizer
		  rightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)rightSwipeGestureRecognizer {
    self.leftSwipeGestureRecognizer = leftSwipeGestureRecognizer;
    self.rightSwipeGestureRecognizer = rightSwipeGestureRecognizer;
    if (self.leftSwipeGestureRecognizer && self.rightSwipeGestureRecognizer) {
        [self.leftSwipeGestureRecognizer addTarget:self action:@selector(swipeHandle:)];
        [self.rightSwipeGestureRecognizer addTarget:self action:@selector(swipeHandle:)];
    }
}

/**
 *  移除手势
 */
- (void)removeSwipeGestureRecognizer {
    if (self.leftSwipeGestureRecognizer) {
        [self.leftSwipeGestureRecognizer removeTarget:self action:@selector(swipeHandle:)];
        self.leftSwipeGestureRecognizer = nil;
    }
    if (self.rightSwipeGestureRecognizer) {
        [self.rightSwipeGestureRecognizer removeTarget:self action:@selector(swipeHandle:)];
        self.rightSwipeGestureRecognizer = nil;
    }
}

@end
