//
//  UIView+Frame.h
//
//  Created by apple on 15/1/6.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SKOscillatoryAnimationToBigger,
    SKOscillatoryAnimationToSmaller,
} SKOscillatoryAnimationType;

@interface UIView (Frame)

// 如果@property在分类里面使用只会自动声明get,set方法,不会实现,并且不会帮你生成成员属性

// 新增视图上下左右边距属性
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;


// view角度变换动画
+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(SKOscillatoryAnimationType)type;
@end
