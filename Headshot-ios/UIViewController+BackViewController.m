//
//  UIViewController+BackViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UIViewController+BackViewController.h"

@implementation UIViewController (BackViewController)

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    UIViewController *backViewController;
    if (numberOfViewControllers >= 2) {
        backViewController = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
    }
    return backViewController;
}

@end
