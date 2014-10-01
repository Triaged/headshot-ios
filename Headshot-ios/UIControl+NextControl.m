//
//  UIControl+NextControl.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UIControl+NextControl.h"
#import <objc/runtime.h>

static char nextControlHashKey;
static char previousControlHashKey;

@implementation UIControl (NextControl)

- (UITextField *)nextControl
{
    return objc_getAssociatedObject(self, &nextControlHashKey);
}

- (UITextField *)previousControl
{
    return objc_getAssociatedObject(self, &previousControlHashKey);
}

- (void)setNextControl:(UITextField *)nextControl
{
    objc_setAssociatedObject(self, &nextControlHashKey, nextControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(nextControl, &previousControlHashKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
