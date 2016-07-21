//
//  SCTabView.h
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTabView : UIView

// title标题
@property (nonatomic, copy) NSArray <NSString *> *titles;

// 子View，个数应该与titles相同，不相同报错
@property (nonatomic, copy) NSArray <__kindof UIView *> *subViews;
// 子ViewController，个数应该与titles相同，不相同报错
@property (nonatomic, copy) NSArray <__kindof UIViewController *> *subViewControllers;

// 字体Font
@property (nonatomic, strong) UIFont *itemFont;
// 背景颜色 默认白色
@property (nonatomic, strong) UIColor *backColor;
// 选中时候的背景颜色 默认红色
@property (nonatomic, strong) UIColor *selectedColor;
// 未选中字体颜色 默认黑色
@property (nonatomic, strong) UIColor *backTextColor;
// 选中的时候字体颜色 默认白色
@property (nonatomic, strong) UIColor *selectedTextColor;

- (instancetype)initFrame:(CGRect)frame titles:(NSArray *)titles subViews:(NSArray *)subViews;
- (instancetype)initFrame:(CGRect)frame titles:(NSArray *)titles subViewControllers:(NSArray *)subViewControllers;

@end
