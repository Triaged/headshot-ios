//
//  DefaultTheme.m
//  Mutuality
//
//  Created by Jeff Ames on 5/20/13.
//  Copyright (c) 2013 Jeffrey Ames. All rights reserved.
//

#import "DefaultTheme.h"

@implementation DefaultTheme

- (NSString *)regularFontName
{
    return @"Whitney-Medium";
}

- (NSString *)lightFontName
{
    return @"Whitney-Book";
}

- (NSString *)boldFontName
{
    return @"Whitney-Semibold";
}

- (UIImage *)backButtonImage
{
    return [UIImage imageNamed:@"navbar_back.png"];
}

- (UIImage *)unreadMessageBackButtonImage
{
    return [UIImage imageNamed:@"navbar_back_notification"];
}

- (UIColor *)darkGrayTextColor
{
    return [UIColor colorWithRed:29/255.0 green:30/255.0 blue:33/255.0 alpha:1.0];
}

- (UIColor *)lightGrayTextColor
{
    return [UIColor colorWithRed:131/255.0 green:137/255.0 blue:148/255.0 alpha:1.0];
}

-(UIColor *)disabledGrayTextColor
{
     return [UIColor colorWithRed:208/255.0 green:212/255.0 blue:223/255.0 alpha:1.0];
}

- (UIColor *)orangeColor
{
    return [UIColor colorWithRed:248/255.0 green:172/255.0 blue:0 alpha:1.0];
}

- (UIColor *)greenColor
{
    return [UIColor colorWithRed:0 green:167/255.0 blue:152/255.0 alpha:1.0];
}

- (UIColor *)blueColor
{
    return [UIColor colorWithRed:0 green:156/255.0 blue:255.0/255.0 alpha:1.0];
}

- (UIColor *)primaryColor
{
    return [self blueColor];
}

- (UIColor *)incomingMessageBubbleColor
{
    return [UIColor colorWithRed:241/255.0 green:240/255.0 blue:240/255.0 alpha:1];
}

- (UIColor *)outgoingMessageBubbleColor
{
    return [UIColor colorWithRed:248/255.0 green:172/255.0 blue:0 alpha:1];
}

- (UIColor *)buttonTintColor
{
    return [self primaryColor];
}

- (UIColor *)tableViewSeparatorColor
{
    return [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
}


- (void)customizeAppearance
{
    UIColor *titleTint = [UIColor blackColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"Whitney-Medium" size:17], NSFontAttributeName, titleTint,NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    UIColor *buttonTint = [self buttonTintColor];;
    NSDictionary *buttonAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                                 fontWithName:@"Whitney-Medium" size:14], NSFontAttributeName, buttonTint,NSForegroundColorAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:buttonTint];
    [[UIButton appearanceWhenContainedIn:[UIActionSheet class], nil] setTitleColor:buttonTint forState:UIControlStateNormal];
    
    NSDictionary *segmentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                                 fontWithName:@"Whitney-Medium" size:13], NSFontAttributeName, buttonTint,NSForegroundColorAttributeName, nil];
    [[UISegmentedControl appearance] setTitleTextAttributes:segmentAttributes forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UINavigationBar appearance].backIndicatorImage = [self.backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [self.backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [SVProgressHUD setBackgroundColor:[self orangeColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

@end
