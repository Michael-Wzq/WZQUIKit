//
//  HomeMenuViewController.m
//  PhotoControlDemo
//
//  Created by lichq on 16/3/16.
//  Copyright © 2016年 lichq. All rights reserved.
//

#import "HomeMenuViewController.h"
#import "MTUIKit.h"

#import "MTUIButtonViewController.h"
#import "MTTabScrollViewController.h"
#import "MTCollectionScrollViewController.h"
@interface CollectionViewCellModel : NSObject
@property(nonatomic, copy) NSString *demoName;
@property(nonatomic, copy) NSString *selectorName;

- (instancetype)initWithDictionary:(NSDictionary *)cellInfo;

@end

@implementation CollectionViewCellModel

- (instancetype)initWithDictionary:(NSDictionary *)cellInfo {
    if (self= [super init]) {
        self.demoName = cellInfo[@"demoName"];
        self.selectorName = cellInfo[@"selectorName"];
    }
    return self;
}

@end



@interface HomeMenuViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HomeMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"首页", nil);
    _datas = [NSMutableArray arrayWithCapacity:0];
    CollectionViewCellModel *mtUIButtonModel = [[CollectionViewCellModel alloc] initWithDictionary:@{@"demoName":@"MTUIButton",
                                                                                                     @"selectorName":NSStringFromSelector(@selector(actionShowMTUIButtonDemo))}];
	
  	[_datas addObject:mtUIButtonModel];

	CollectionViewCellModel *mtScrollTabViewModel = [[CollectionViewCellModel alloc] initWithDictionary:@{@"demoName":@"MTScrollTabView",
																									 @"selectorName":NSStringFromSelector(@selector(actionShowMTScrollTabViewDemo))}];
	
	
	
	[_datas addObject:mtScrollTabViewModel];
	CollectionViewCellModel *mtCollectionScrollViewModel = [[CollectionViewCellModel alloc] initWithDictionary:@{@"demoName":@"MTCollectionScrollView",
																										  @"selectorName":NSStringFromSelector(@selector(actionShowMTCollectionScrollViewDemo))}];
	
	
	
	[_datas addObject:mtCollectionScrollViewModel];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:1000];
    CollectionViewCellModel *cellModel = _datas[indexPath.item];
    label.text = cellModel.demoName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCellModel *selectedCellModel = _datas[indexPath.item];
    if (selectedCellModel.selectorName) {
        SEL actionSelector = NSSelectorFromString(selectedCellModel.selectorName);
        if ([self respondsToSelector:actionSelector]) {
            [self performSelector:actionSelector withObject:nil afterDelay:0.0];
        }
    }
}

- (void)actionShowMTUIButtonDemo {
    MTUIButtonViewController *viewController = [[MTUIButtonViewController alloc] initWithNibName:@"MTUIButtonViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)actionShowMTScrollTabViewDemo {
	MTTabScrollViewController *viewController = [[MTTabScrollViewController alloc] initWithNibName:@"MTTabScrollViewController" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionShowMTCollectionScrollViewDemo {
	MTCollectionScrollViewController *viewController = [[MTCollectionScrollViewController alloc] initWithNibName:@"MTCollectionScrollViewController" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
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
