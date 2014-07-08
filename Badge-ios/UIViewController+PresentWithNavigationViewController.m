//
//  UIViewController+PresentWithNavigationViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UIViewController+PresentWithNavigationViewController.h"
#import "TRNavigationController.h"

@implementation UIViewController (PresentWithNavigationViewController)

- (void)presentViewControllerWithNav:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    TRNavigationController *navigationController = [[TRNavigationController alloc] initWithRootViewController:viewControllerToPresent];
    navigationController.navigationBar.translucent = NO;
    [self presentViewController:navigationController animated:flag completion:completion];
}

@end
