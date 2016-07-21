//
//  SCTabView.m
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import "SCTabView.h"
#import "SCItemView.h"
#import <objc/runtime.h>

static NSString * const ContentOffset = @"contentOffset";
static NSString * const isInstalledKey;

@interface SCTabView () <UIScrollViewDelegate, SCItemViewDelegate>

@property (nonatomic, strong) UIScrollView *itemScrollView;
@property (nonatomic, strong) UIScrollView *rootScrollView;
@property (nonatomic, strong) SCItemView *itemView;

@end

@implementation SCTabView {
    // 滑动开始，rootScrollView 的信息
    NSInteger startIndex;
    CGFloat   startContentOffsetX;
    // 是否滑动itemview，当接收到回调的时候不应该去改变itemView，itemView自己变
    BOOL shouldScrollItemView;
}

#pragma mark - Getter Setter

// 获取self 宽度
- (CGFloat)width {
    return CGRectGetWidth(self.bounds);
}

// 获取self 高度
- (CGFloat)height {
    return CGRectGetHeight(self.bounds);
}

// 获取item高度
- (CGFloat)itemHeight {
    return self.height * 0.2 > 44 ? 44 : self.height * 0.2;
}

// 返回Scrollview 的高度
- (CGFloat)scrollViewHeight {
    return self.height - self.itemHeight;
}

- (UIScrollView *)itemScrollView {
    if (_itemScrollView == nil) {
        _itemScrollView = [[UIScrollView alloc] initWithFrame:self.itemScrollViewFrame];
        _itemScrollView.delegate = self;
        _itemScrollView.pagingEnabled = NO;
        _itemScrollView.showsVerticalScrollIndicator = NO;
        _itemScrollView.showsHorizontalScrollIndicator = NO;
        _itemScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_itemScrollView];
    }
    return _itemScrollView;
}

- (UIScrollView *)rootScrollView {
    if (_rootScrollView == nil) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:self.rootScrollViewFrame];
        _rootScrollView.delegate = self;
        _rootScrollView.pagingEnabled = YES;
        _rootScrollView.backgroundColor = self.backgroundColor;
        _rootScrollView.showsHorizontalScrollIndicator = NO;
        _rootScrollView.alwaysBounceHorizontal = YES;
        [self addSubview:_rootScrollView];
    }
    return _rootScrollView;
}

// 获取itemView 的frame
- (CGRect)itemScrollViewFrame {
    return CGRectMake(0, 0, self.width, self.itemHeight);
}

// 获取rootView 的frame
- (CGRect)rootScrollViewFrame {
    return CGRectMake(0, self.itemHeight, self.width, self.height - self.itemHeight);
}

#pragma mark - Init

- (instancetype)initFrame:(CGRect)frame titles:(NSArray *)titles subViews:(NSArray *)subViews {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.subViews = subViews;
        [self commonInit];
    }
    return self;
}

- (instancetype)initFrame:(CGRect)frame titles:(NSArray *)titles subViewControllers:(NSArray *)subViewControllers {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.subViewControllers = subViewControllers;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"Wrong method" reason:@"Please use initWithTitles:subViews: or initWithFrame: instead" userInfo:nil];
    return nil;
}

- (void)commonInit {
    NSInteger count;
    if (self.subViews.count > 0) {
        count = self.subViews.count;
    } else if (self.subViewControllers.count > 0) {
        count = self.subViewControllers.count;
    }
    if (self.titles.count != count && self.titles.count == 0) {
        @throw [NSException exceptionWithName:@"Wrong Init" reason:@"titles's count not equal subViews's count" userInfo:nil];
        return;
    }
    [self initItemScrollView];
    [self initRootScrollView];
}

#pragma mark - Private

- (void)initItemScrollView {
    SCItemView *itemView = [[SCItemView alloc] initWithTitles:self.titles height:self.itemHeight width:self.width];
    itemView.backColor = self.backColor;
    itemView.selectedColor = self.selectedColor;
    itemView.backTextColor = self.backTextColor;
    itemView.selectedTextColor = self.selectedTextColor;
    itemView.itemFont = self.itemFont;
    itemView.delegate = self;
    [self.itemScrollView addSubview:itemView];
    self.itemView = itemView;
    self.itemScrollView.contentSize = itemView.frame.size;
}

- (void)initRootScrollView {
    if (self.subViews.count > 0) {
        self.rootScrollView.contentSize = CGSizeMake(self.width * self.subViews.count, self.scrollViewHeight);
        for (int i = 0; i < self.subViews.count; i++) {
            UIView *view = self.subViews[i];
            view.frame = CGRectMake(i * self.width, 0, self.width, self.height);
            [self.rootScrollView addSubview:view];
        }
    } else if (self.subViewControllers.count > 0) {
        self.rootScrollView.contentSize = CGSizeMake(self.width * self.subViewControllers.count, self.scrollViewHeight);
        for (int i = 0; i < self.subViewControllers.count; i++) {
            // 用运行时给各个controller增加是否被添加标识，用来实现懒加载
            UIViewController *viewController = self.subViewControllers[i];
            objc_setAssociatedObject(viewController, &isInstalledKey, @(0), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [self addSubViewController:0];
    }
}

- (void)addSubViewController:(NSInteger)index {
    UIViewController *viewController = self.subViewControllers[index];
    BOOL isinstalled = [objc_getAssociatedObject(viewController, &isInstalledKey) boolValue];
    if (isinstalled) {
        return;
    }
    viewController.view.frame = CGRectMake(index * self.width, 0, self.width, self.height);
    [self.rootScrollView addSubview:viewController.view];
    objc_setAssociatedObject(viewController, &isInstalledKey, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 更新scrollView的子视图， 采用懒加载方式
- (void)updateRootScrollViewSubViewControllers {
    CGFloat contentOffsetX = self.rootScrollView.contentOffset.x;
    if ((NSInteger)contentOffsetX % (NSInteger)self.width == 0) {
        NSInteger index = (int)(contentOffsetX / self.width);
        [self addSubViewController:index];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.rootScrollView) {
        startContentOffsetX = scrollView.contentOffset.x;
        startIndex = (NSInteger)(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
        shouldScrollItemView = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.rootScrollView == scrollView && shouldScrollItemView) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (contentOffsetX <= 0 || contentOffsetX >= self.width * (self.titles.count - 1)) {
            return;
        }
        CGFloat progress = (contentOffsetX - startContentOffsetX) / self.width;
        if (progress >= 1) {
            progress = 1;
        }
        if (progress <= -1) {
            progress = -1;
        }
        NSInteger toIndex = startIndex + (progress > 0 ? 1 : -1);
//        NSLog(@"startIndex == %d, progress == %f, toIndex == %d", (int)startIndex, progress, (int)toIndex);
        if (toIndex < 0) {
            return;
        }
        [self.itemView setIndicatorViewFromIndex:startIndex toIndex:toIndex progress:fabs(progress)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.rootScrollView == scrollView) {
        if (self.subViewControllers.count) {
            [self updateRootScrollViewSubViewControllers];
        }
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        contentOffsetX = MAX(contentOffsetX, 0);
        NSInteger index = (NSInteger)(contentOffsetX / CGRectGetWidth(scrollView.bounds));
        [self.itemView setIndicatorViewToIndex:index];
    }
}

#pragma mark - SCItemViewDelegate

- (void)itemView:(SCItemView *)view didSelectedIndex:(NSInteger)index {
    shouldScrollItemView = NO;
    [self.rootScrollView setContentOffset:CGPointMake(index * self.width, 0) animated:NO];
    if (self.subViewControllers.count) {
        // 手动更新子视图
        [self updateRootScrollViewSubViewControllers];
    }
    shouldScrollItemView = YES;
}

- (void)dealloc {
    NSLog(@"我死了😄");
}




@end
