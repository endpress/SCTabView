//
//  NSString+SCTableView.m
//  SCTabView
//
//  Created by ZhangSC on 16/5/17.
//  Copyright © 2016年 ZSC. All rights reserved.
//

#import "NSString+SCTableView.h"

@implementation NSString (SCTableView)

- (CGSize)sizeWithFont {
    CGSize size = [self boundingRectWithSize:CGSizeMake(250, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14]} context:nil].size;
    return size;
}

@end
