//
//  ViewController.m
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import "ViewController.h"
#import "SCTabView.h"
#import "FirstViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@property (nonatomic, strong) SCTabView *scView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)add:(id)sender {
    UIView *view1 = [UIView new];
    view1.backgroundColor = [UIColor redColor];
    UIView *view2 = [UIView new];
    view2.backgroundColor = [UIColor greenColor];
    UIView *view3 = [UIView new];
    view3.backgroundColor = [UIColor redColor];
    UIView *view4 = [UIView new];
    view4.backgroundColor = [UIColor greenColor];
    self.scView = [[SCTabView alloc] initFrame:CGRectMake(50, 50, 200, 400) titles:@[@"销量", @"价格555", @"测试长度呢", @"haha"] subViews:@[view1, view2, view3, view4]];
//    FirstViewController *vc1 = [[FirstViewController alloc] init];
//    SecondViewController *vc2 = [[SecondViewController alloc] init];
//    self.scView = [[SCTabView alloc] initFrame:CGRectMake(50, 50, 200, 400) titles:@[@"销量", @"价格555"] subViewControllers:@[vc1, vc2]];
    self.scView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.scView];
}
- (IBAction)delete:(id)sender {
    [self.scView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
