//
//  OnboardNavigationController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnboardViewController;
@protocol OnboardViewControllerDelegate <NSObject>

- (void)onboardViewController:(UIViewController<OnboardViewController> *)viewController doneButtonTouched:(id)sender;
- (void)onboardViewController:(UIViewController<OnboardViewController> *)viewController skipButtonTouched:(id)sender;

@end

@protocol OnboardViewController <NSObject>

@property (weak, nonatomic) id<OnboardViewControllerDelegate> delegate;

@end

@interface OnboardNavigationController : UINavigationController <OnboardViewControllerDelegate>

@end

