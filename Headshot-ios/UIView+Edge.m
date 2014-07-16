//
//  UIView+Edge.m
//  ZipDigs
//
//  Created by Jeffrey Ames on 3/10/14.
//  Copyright (c) 2014 ZipDigs. All rights reserved.
//

#import "UIView+Edge.h"

@interface EdgeView : UIView

@property (assign, nonatomic) UIRectEdge edge;

@end

@implementation UIView (Edge)

- (void)addEdge:(UIRectEdge)edge width:(CGFloat)width color:(UIColor *)color
{
    [self addEdge:edge insets:UIEdgeInsetsZero width:width color:color];
}

- (void)addEdge:(UIRectEdge)edge insets:(UIEdgeInsets)edgeInsets width:(CGFloat)width color:(UIColor *)color
{
    [self removeEdge:edge];
    UIRectEdge left = edge & UIRectEdgeLeft;
    UIRectEdge right = edge & UIRectEdgeRight;
    UIRectEdge top = edge & UIRectEdgeTop;
    UIRectEdge bottom = edge & UIRectEdgeBottom;
    if (left) {
        [self addLeftEdge:width insets:edgeInsets color:color];
    }
    if (right) {
        [self addRightEdge:width insets:edgeInsets color:color];
    }
    if (top) {
        [self addTopEdge:width insets:edgeInsets color:color];
    }
    if (bottom) {
        [self addBottomEdge:width insets:edgeInsets color:color];
    }
}

- (void)addLeftEdge:(CGFloat)width insets:(UIEdgeInsets)edgeInsets color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    edgeView.edge = UIRectEdgeLeft;
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    CGFloat height = self.bounds.size.height - edgeInsets.top - edgeInsets.bottom;
    frame.size = CGSizeMake(width, height);
    frame.origin.y = edgeInsets.top;
    resizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    if (edgeInsets.top > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleBottomMargin;
    }
    if (edgeInsets.bottom > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleTopMargin;
    }
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addRightEdge:(CGFloat)width insets:(UIEdgeInsets)insets color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    edgeView.edge = UIRectEdgeRight;
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(width, self.bounds.size.height - insets.top - insets.bottom);
    frame.origin.x = self.bounds.size.width - frame.size.width;
    frame.origin.y = insets.top;
    resizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    resizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    if (insets.top > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleBottomMargin;
    }
    if (insets.bottom > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleTopMargin;
    }
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addTopEdge:(CGFloat)width insets:(UIEdgeInsets)insets color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    edgeView.edge = UIRectEdgeTop;
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.bounds.size.width - insets.left - insets.bottom, width);
    frame.origin.x = insets.left;
    resizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    if (insets.left > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleRightMargin;
    }
    if (insets.right > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleLeftMargin;
    }
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)addBottomEdge:(CGFloat)width insets:(UIEdgeInsets)insets color:(UIColor *)color
{
    EdgeView *edgeView = [[EdgeView alloc] init];
    edgeView.edge = UIRectEdgeBottom;
    UIViewAutoresizing resizing;
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.bounds.size.width - insets.left - insets.right, width);
    frame.origin.y = self.bounds.size.height - frame.size.height;
    frame.origin.x = insets.left;
    resizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    if (insets.left > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleRightMargin;
    }
    if (insets.right > 0) {
        resizing = resizing | UIViewAutoresizingFlexibleLeftMargin;
    }
    edgeView.frame = frame;
    edgeView.autoresizingMask = resizing;
    edgeView.backgroundColor = color;
    [self addSubview:edgeView];
}

- (void)removeEdge:(UIRectEdge)edge
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EdgeView class]]) {
            EdgeView *edgeView = (EdgeView *)view;
            if (edgeView.edge & edge) {
                [view removeFromSuperview];
            }
        }
    }
}

- (void)removeAllEdges
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EdgeView class]]) {
                [view removeFromSuperview];
        }
    }
}

@end

@implementation EdgeView


@end


