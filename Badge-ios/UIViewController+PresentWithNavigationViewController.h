//
//  UIViewController+PresentWithNavigationViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PresentWithNavigationViewController)

- (void)presentViewControllerWithNav:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

@end
