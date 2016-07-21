//
//  SCItemView.m
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import "SCItemView.h"

static CGFloat const Padding = 20;

@interface SCItemView ()

// 两个数组，一个显示正常，另一个显示被选中的
// backLabels 显示正常， font 显示被选中
@property (nonatomic, copy) NSArray <UILabel *> *backLabels;
@property (nonatomic, copy) NSArray <UILabel *> *frontLabels;

// 存放label的frame
@property (nonatomic, strong) NSMutableArray <NSValue *> *labelFrames;

@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UIView *indictorView;

@end

@implementation SCItemView {
    BOOL isAnimating;
}

- (UIColor *)backColor {
    if (_backColor == nil) {
        _backColor = [UIColor whiteColor];
    }
    return _backColor;
}

- (UIColor *)backTextColor {
    if (_backTextColor == nil) {
        _backTextColor = [UIColor blackColor];
    }
    return _backTextColor;
}

- (UIColor *)selectedColor {
    if (_selectedColor == nil) {
        _selectedColor = [UIColor redColor];
    }
    return _selectedColor;
}

- (UIColor *)selectedTextColor {
    if (_selectedTextColor == nil) {
        _selectedTextColor = [UIColor whiteColor];
    }
    return _selectedTextColor;
}

- (UIView *)frontView {
    if (_frontView == nil) {
        _frontView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _frontView;
}

- (UIView *)indictorView {
    if (_indictorView == nil) {
        _indictorView = [[UIView alloc] init];
        _indictorView.backgroundColor = [UIColor blueColor];
        _indictorView.layer.cornerRadius = 8.0;
    }
    return _indictorView;
}

#pragma mark - Init

- (instancetype)initWithTitles:(NSArray *)titles height:(CGFloat)height width:(CGFloat)width {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.titles = titles;
        self.height = height;
        self.width = width;
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark -Private

- (void)commonInit {
    if (self.titles.count < 1) return;
    if (self.height == 0)      return;
    if (self.width == 0)       return;

    self.backgroundColor = self.backColor;
    self.labelFrames = [NSMutableArray arrayWithCapacity:self.titles.count];
    // 默认第一个距离左边为padding
    CGFloat selfWidth = Padding;
    // 添加labels
    for (NSString *title in self.titles) {
        // 底层labels
        UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(selfWidth, 0, 50, self.height)];
        backLabel.text = title;
        backLabel.textColor = self.backTextColor;
        backLabel.textAlignment = NSTextAlignmentCenter;
        backLabel.backgroundColor = self.backColor;
        if (self.itemFont) {
            backLabel.font = self.itemFont;
        }
        [backLabel sizeToFit];
        CGRect frame = backLabel.frame;
        // 把label放到中心位置
        frame = CGRectMake(selfWidth, (self.height - CGRectGetHeight(frame)) * 0.5, MAX(CGRectGetWidth(frame), 20), CGRectGetHeight(frame));
        backLabel.frame = frame;
        [self addSubview:backLabel];
        
        // 上层labels
        UILabel *frontLabel = [[UILabel alloc] initWithFrame:frame];
        frontLabel.text = title;
        frontLabel.textColor = self.selectedTextColor;
        frontLabel.backgroundColor = self.selectedColor;
        frontLabel.textAlignment = NSTextAlignmentCenter;
        if (self.itemFont) {
            frontLabel.font = self.itemFont;
        }
        [self.frontView addSubview:frontLabel];
        
        // 将labelframe 保存
        NSValue *frameValue = [NSValue valueWithCGRect:backLabel.frame];
        [self.labelFrames addObject:frameValue];
        // 计算宽度
        selfWidth += CGRectGetWidth(backLabel.bounds) + Padding;
    }
    selfWidth = MAX(selfWidth, self.width);
    self.frame = CGRectMake(0, 0, selfWidth, self.height);
    self.frontView.frame = self.bounds;
    self.frontView.backgroundColor = self.selectedColor;
    [self addSubview:self.frontView];
    self.frontView.maskView = self.indictorView;
    [self setIndicatorViewToIndex:0];
    [self startGesture];
}

- (void)startGesture {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:gesture];
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    NSInteger index = [self getIndexWithPoint:point];
    if (index == -1) {
        // 没找到匹配的
        return;
    }
    [self setIndicatorViewToIndex:index];
    if ([self.delegate respondsToSelector:@selector(itemView:didSelectedIndex:)]) {
        [self.delegate itemView:self didSelectedIndex:index];
    }
}

/**
 获取点击位置的index
 */
- (NSInteger)getIndexWithPoint:(CGPoint)point {
    for (int i = 0; i < self.labelFrames.count; i++) {
        CGRect frame;
        [(NSValue *)self.labelFrames[i] getValue:&frame];
        CGRect largeFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(-8, -8, -8, -8));
        if (CGRectContainsPoint(largeFrame, point)) {
            return i;
        }
    }
    return -1;              // -1 代表没找到
}

// 获取index位置的labelFrame
- (CGRect)frameForIndex:(NSInteger)index {
    if (index < 0 || index >= self.titles.count) {
        NSLog(@"出错了，😄 index == %d", (int)index);
        return CGRectNull;
    }
    CGRect frame;
    [(NSValue *)self.labelFrames[index] getValue:&frame];
    return frame;
}

// 计算两个Frame的中间值，根据progress
- (CGRect)frameFormFrame:(CGRect)startFrame toFrame:(CGRect)toFrame progress:(CGFloat)progress {
    CGFloat originX = startFrame.origin.x + (toFrame.origin.x - startFrame.origin.x) * progress;
    CGFloat originY = startFrame.origin.y + (toFrame.origin.y - startFrame.origin.y) * progress;
    CGFloat width = startFrame.size.width + (toFrame.size.width - startFrame.size.width) * progress;
    CGFloat height = startFrame.size.height + (toFrame.size.height - startFrame.size.height) * progress;
    return CGRectMake(originX, originY, width, height);
}

#pragma mark - Public

- (void)setIndicatorViewFromIndex:(NSInteger)startIndex toIndex:(NSInteger)index progress:(CGFloat)progress {
    CGRect startFrame = UIEdgeInsetsInsetRect([self frameForIndex:startIndex], UIEdgeInsetsMake(-8, -8, -8, -8));
    CGRect targetFrame = UIEdgeInsetsInsetRect([self frameForIndex:index], UIEdgeInsetsMake(-8, -8, -8, -8));
    self.indictorView.frame = [self frameFormFrame:startFrame toFrame:targetFrame progress:progress];
    if (progress >= 0.99) {
        [self setIndicatorViewToIndex:index];
    }
}

- (void)setIndicatorViewToIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.titles.count) {
        return;
    }
    CGRect frame = [self frameForIndex:index];
    if (CGRectEqualToRect(frame, CGRectNull)) {
        return;
    }
    if (CGRectEqualToRect(frame, self.indictorView.frame)) {
        return;
    }
    if (isAnimating) {
        return;
    }
    isAnimating = YES;
    CGRect indicatorFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(-8, -8, -8, -8));
    [self adjustSuperViewWithRect:indicatorFrame];
    [UIView animateWithDuration:0.2 animations:^{
        self.indictorView.frame = indicatorFrame;
    } completion:^(BOOL finished) {
        isAnimating = NO;
    }];
}

/**
 调整父控件，让选中的label显示在屏幕中间
 */
- (void)adjustSuperViewWithRect:(CGRect)rect {
    // 把Frame变到self.width，显示在中间
    CGFloat width = CGRectGetWidth(rect);
    CGRect largeRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, -(self.width - width) * 0.5, 0, -(self.width - width) * 0.5));
    UIScrollView *superView = (UIScrollView *)self.superview;
    [superView scrollRectToVisible:largeRect animated:YES];
}

@end
