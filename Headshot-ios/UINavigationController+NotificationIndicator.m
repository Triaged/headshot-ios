//
//  UINavigationController+NotificationIndicator.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "UINavigationController+NotificationIndicator.h"

@implementation UINavigationController (NotificationIndicator)

- (void)showNotificationIndicator
{
    UIImage *backButtonImage = [[[ThemeManager sharedTheme] unreadMessageBackButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationBar.backIndicatorImage = backButtonImage;
    self.navigationBar.backIndicatorTransitionMaskImage = backButtonImage;
}

@end
