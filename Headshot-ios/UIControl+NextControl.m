//
//  UIControl+NextControl.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UIControl+NextControl.h"
#import <objc/runtime.h>

static char defaultHashKey;

@implementation UIControl (NextControl)

- (UITextField *)nextControl
{
    return objc_getAssociatedObject(self, &defaultHashKey);
}

- (void)setNextControl:(UITextField *)nextControl
{
    objc_setAssociatedObject(self, &defaultHashKey, nextControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
