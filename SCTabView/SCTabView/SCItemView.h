//
//  SCItemView.h
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCItemView;
@protocol SCItemViewDelegate <NSObject>

- (void)itemView:(SCItemView *)view didSelectedIndex:(NSInteger)index;

@end

@interface SCItemView : UIView

// 标题
@property (nonatomic, copy) NSArray <NSString *> *titles;

// 控件高度
@property (nonatomic, assign) CGFloat height;
// 父控件宽度
@property (nonatomic, assign) CGFloat width;
// 字体
@property (nonatomic, strong) UIFont *itemFont;
// 背景颜色 默认白色
@property (nonatomic, strong) UIColor *backColor;
// 选中时候的背景颜色 默认红色
@property (nonatomic, strong) UIColor *selectedColor;
// 未选中字体颜色 默认黑色
@property (nonatomic, strong) UIColor *backTextColor;
// 选中的时候字体颜色 默认白色
@property (nonatomic, strong) UIColor *selectedTextColor;
// 代理
@property (nonatomic, weak) id<SCItemViewDelegate> delegate;


/*  width 为父控价的width
    当titles 个数比较少的时候，根据width来设定
*/
- (instancetype)initWithTitles:(NSArray *)titles height:(CGFloat)height width:(CGFloat)width;

/**
 设置IndicatorView的位置
 */
- (void)setIndicatorViewToIndex:(NSInteger)index;
- (void)setIndicatorViewFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)index progress:(CGFloat)progress;

@end
