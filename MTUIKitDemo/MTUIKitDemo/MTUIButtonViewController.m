//
//  MTUIButtonViewController.m
//  MTUIKitDemo
//
//  Created by meitu on 16/5/31.
//  Copyright © 2016年 ph. All rights reserved.
//

#import "MTUIButtonViewController.h"

#import "MTUIKit.h"

#define X 88
#define Y 200

static double topImgValue;
static double leftImgValue;
static double bottomImgValue;
static double rightImgValue;

static double topLabelValue;
static double leftLabelValue;
static double bottomLabelValue;
static double rightLabelValue;

@interface MTUIButtonViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray *_directionWay;
    NSArray *_languageType;
    NSArray *_bgFitWay;
    NSString *_normalStr;
}
- (IBAction)switchColor:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *colorSwitch;

- (IBAction)mySwitchChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;

- (IBAction)topStepperClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *topStepper;
@property (weak, nonatomic) IBOutlet UITextField *topTextField;

- (IBAction)leftStepperClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *leftStepper;
@property (weak, nonatomic) IBOutlet UITextField *leftTextField;

- (IBAction)bottomStepperClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *bottomStepper;
@property (weak, nonatomic) IBOutlet UITextField *bottomTextField; 

- (IBAction)rightStepperClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *rightStepper;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;

@property (nonatomic, strong) MTUIButton *myButton;
@end

@implementation MTUIButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
     _normalStr = @"美化图片";
    
    _directionWay = @[@"图片在上标题在下",
                      @"图片在下标题在上",
                      @"图片在左标题在右",
                      @"图片在右标题在左",
                      ];
    
    _languageType = @[@"中文",
                      @"英语",
                      ];
    
    _bgFitWay = @[@"背景图片压缩",
                  @"背景图片不压缩"
                  ];
    
    //pickerView初始化
    self.myPickerView.dataSource = self;
    self.myPickerView.delegate = self;
    
    [self setupTextfield];
    
    [self createButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerView数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger count;
    if (component == 0) {
        count = _directionWay.count;
    } else if (component == 1) {
        count = _languageType.count;
    } else if (component == 2) {
        count = _bgFitWay.count;
    }
    return count;//_directionWay.count;
} 

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        //只有切换布局方式的时候重置所有信息
        [self clearAllInfo];
        switch (row) {
            case 0: //图片在上标题在下
                [self changeUpDirect];
                break;
            case 1: //图片在下标题在上
                [self changeDownDirect];
                break;
            case 2: //图片在左标题在右
                [self changeLeftDirect];
                break;
            case 3: //图片在右标题在左
                [self changeRightDirect];
                break;
            default:
                break;
        }
    } else if (component == 1) {

        _normalStr = row < 1 ? @"美化图片" : @"Beatuy Picture";
        [self setTitleWithLanguage];
    } else if (component == 2) {
        
        BOOL bFit = row > 0 ? YES : NO;
        _myButton.bgAspectFit = bFit;
        [self refreshSubViews];
//        [_myButton setNeedsLayout];
    }
}

- (void)setTitleWithLanguage {
    [_myButton setTitle:_normalStr forState:UIControlStateNormal];
    [_myButton setTitle:_normalStr forState:UIControlStateHighlighted];
    [_myButton setTitle:_normalStr forState:UIControlStateSelected];
    [_myButton setTitle:_normalStr forState:UIControlStateDisabled];
}

#pragma mark UIPickerView代理方法
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *pickerViewStr;
    if (component == 0) {
        pickerViewStr = [_directionWay objectAtIndex:row];
    } else if (component == 1) {
        pickerViewStr = [_languageType objectAtIndex:row];
    } else if (component == 2) {
        pickerViewStr = [_bgFitWay objectAtIndex:row];
    }
    return pickerViewStr;//[_directionWay objectAtIndex:row];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = nil;
    if (component == 0) {
        //计算字体的Size
        label = [self calculateTitleFont:[_directionWay objectAtIndex:row]];
    } else if (component == 1) {
        label = [self calculateTitleFont:[_languageType objectAtIndex:row]];
    } else if (component == 2) {
        label = [self calculateTitleFont:[_bgFitWay objectAtIndex:row]];
    }
    return label;
}

- (UILabel *)calculateTitleFont:(NSString *)title {
    UILabel *myView = [[UILabel alloc] init];
    myView.font = [UIFont systemFontOfSize:13.0];
    myView.text = title;
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:13.0]};
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    myView.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
    myView.textAlignment = NSTextAlignmentCenter;
    return myView;
}

- (void)createButton {
    _myButton = [self setupMTUIButtomWith:CGRectMake(100, 64, 200, 200)];
    [self.view addSubview:_myButton]; 
}

- (MTUIButton *)setupMTUIButtomWith:(CGRect)frame {
    
    MTUIButton *button = [[MTUIButton alloc] initWithFrame:frame];
    
    button.imageView.backgroundColor = [UIColor blueColor];
    button.titleLabel.backgroundColor = [UIColor blackColor];
    button.backgroundColor = [UIColor lightGrayColor];
    
    [button setImage:[UIImage imageNamed:@"icon_home_beauty"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"home_block_red_a"] forState:UIControlStateNormal];
    [button setTitle:_normalStr forState:UIControlStateNormal];
    [button setTitle:_normalStr forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0]; 
    return button;
}

- (void)clearEdgeInsets {
    _myButton.contentEdgeInsets = UIEdgeInsetsZero;
    _myButton.imageEdgeInsets = UIEdgeInsetsZero;
    _myButton.titleEdgeInsets = UIEdgeInsetsZero;
}

- (void)changeUpDirect { 
    NSLog(@"changeUpDirect");
    [self clearEdgeInsets];
    _myButton.horizontalLayout = NO;
    _myButton.iconDown = NO;
    
    [self refreshSubViews];
}

- (void)changeDownDirect {
    NSLog(@"changeDownDirect");
    [self clearEdgeInsets];
    _myButton.horizontalLayout = NO;
    _myButton.iconDown = YES;

    [self refreshSubViews];
}

- (void)changeLeftDirect {
    [self clearEdgeInsets];
    //左右布局
    _myButton.horizontalLayout = YES;
    _myButton.iconRight = NO;

    [self refreshSubViews];
}

- (void)changeRightDirect {
    [self clearEdgeInsets];
    //左右布局 
    _myButton.horizontalLayout = YES;
    _myButton.iconRight = YES;
    
    [self refreshSubViews];
}

- (void)refreshSubViews {
    [_myButton setNeedsLayout];
    [_myButton layoutIfNeeded];
}

- (IBAction)mySwitchChanged:(id)sender {
    NSLog(@"mySwitchChanged%zd",self.mySwitch.on);
    if (self.mySwitch.on) {
        //图片
        self.topTextField.text = [NSString stringWithFormat:@"%0.0lf",topImgValue];
        self.leftTextField.text = [NSString stringWithFormat:@"%0.0lf",leftImgValue];
        self.bottomTextField.text = [NSString stringWithFormat:@"%0.0lf",bottomImgValue];
        self.rightTextField.text = [NSString stringWithFormat:@"%0.0lf",rightImgValue];
    } else {
        //文字
        self.topTextField.text = [NSString stringWithFormat:@"%0.0lf",topLabelValue];
        self.leftTextField.text = [NSString stringWithFormat:@"%0.0lf",leftLabelValue];
        self.bottomTextField.text = [NSString stringWithFormat:@"%0.0lf",bottomLabelValue];
        self.rightTextField.text = [NSString stringWithFormat:@"%0.0lf",rightLabelValue];
    }
}

- (IBAction)topStepperClicked:(id)sender {
    NSLog(@"topStepperClicked%f",self.topStepper.value);
    if (self.mySwitch.on) {
        //计算图片的EdgeInsets
        double value = self.topStepper.value + self.topStepper.stepValue - 1 - topLabelValue;
        self.topTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        topImgValue = value;
        
        _myButton.imageEdgeInsets = UIEdgeInsetsMake(topImgValue, leftImgValue, bottomImgValue, rightImgValue);
    } else {
        //计算标题的EdgeInsets
        double value = self.topStepper.value + self.topStepper.stepValue - 1 - topImgValue;
        self.topTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        topLabelValue = value;
        
        _myButton.titleEdgeInsets = UIEdgeInsetsMake(topLabelValue, leftLabelValue, bottomLabelValue, rightLabelValue);
    }
}

- (IBAction)leftStepperClicked:(id)sender {
    if (self.mySwitch.on) {
        //计算图片的EdgeInsets
        double value = self.leftStepper.value + self.leftStepper.stepValue - 1 - leftLabelValue;
        self.leftTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        leftImgValue = value;
        
        _myButton.imageEdgeInsets = UIEdgeInsetsMake(topImgValue, leftImgValue, bottomImgValue, rightImgValue);
    } else {
        //计算标题的EdgeInsets
        double value = self.leftStepper.value + self.leftStepper.stepValue - 1 - leftImgValue;
        self.leftTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        leftLabelValue = value;
        
        _myButton.titleEdgeInsets = UIEdgeInsetsMake(topLabelValue, leftLabelValue, bottomLabelValue, rightLabelValue);
    }
}

- (IBAction)bottomStepperClicked:(id)sender {
    if (self.mySwitch.on) {
        //计算图片的EdgeInsets
        double value = self.bottomStepper.value + self.bottomStepper.stepValue - 1 - bottomLabelValue;
        self.bottomTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        bottomImgValue = value;
        
        _myButton.imageEdgeInsets = UIEdgeInsetsMake(topImgValue, leftImgValue, bottomImgValue, rightImgValue);
    } else {
        //计算标题的EdgeInsets
        double value = self.bottomStepper.value + self.bottomStepper.stepValue - 1 - bottomImgValue;
        self.bottomTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        bottomLabelValue = value;
        
        _myButton.titleEdgeInsets = UIEdgeInsetsMake(topLabelValue, leftLabelValue, bottomLabelValue, rightLabelValue);
    }
}

- (IBAction)rightStepperClicked:(id)sender {
    if (self.mySwitch.on) {
        //计算图片的EdgeInsets
        double value = self.rightStepper.value + self.rightStepper.stepValue - 1 - rightLabelValue;
        self.rightTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        rightImgValue = value;
        
        _myButton.imageEdgeInsets = UIEdgeInsetsMake(topImgValue, leftImgValue, bottomImgValue, rightImgValue);
    } else {
        //计算标题的EdgeInsets
        double value = self.rightStepper.value + self.rightStepper.stepValue - 1 - rightImgValue;
        self.rightTextField.text = [NSString stringWithFormat:@"%0.0lf",value];
        rightLabelValue = value;
        
        _myButton.titleEdgeInsets = UIEdgeInsetsMake(topLabelValue, leftLabelValue, bottomLabelValue, rightLabelValue);
    }
}

- (void)setupTextfield {
    self.topTextField.text = @"0";
    self.leftTextField.text = @"0";
    self.bottomTextField.text = @"0";
    self.rightTextField.text = @"0";
    
    self.topTextField.enabled = NO;
    self.leftTextField.enabled = NO;
    self.bottomTextField.enabled = NO;
    self.rightTextField.enabled = NO;
    

}

- (void)clearAllInfo {
    //重置Textfield
    [self setupTextfield];
    
    //清楚所有数据
    topImgValue = 0;
    leftImgValue = 0;
    bottomImgValue = 0;
    rightImgValue = 0;
    
    topLabelValue = 0;
    leftLabelValue = 0;
    bottomLabelValue = 0;
    rightLabelValue = 0;
    
    self.topStepper.value = 0;
    self.leftStepper.value = 0;
    self.bottomStepper.value = 0;
    self.rightStepper.value = 0;
}

- (IBAction)switchColor:(id)sender {
    if (self.colorSwitch.on) {
        _myButton.imageView.backgroundColor = [UIColor blueColor];
        _myButton.titleLabel.backgroundColor = [UIColor blackColor];
        _myButton.backgroundColor = [UIColor lightGrayColor];
    } else {
        _myButton.imageView.backgroundColor = [UIColor clearColor];
        _myButton.titleLabel.backgroundColor = [UIColor clearColor];
        _myButton.backgroundColor = [UIColor clearColor];
    }
}
@end
