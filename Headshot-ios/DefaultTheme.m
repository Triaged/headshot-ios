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

- (UIColor *)darkGrayTextColor
{
    return [UIColor colorWithWhite:38/255.0 alpha:1.0];
}

- (UIColor *)lightGrayTextColor
{
    return [UIColor colorWithWhite:119/255.0 alpha:1.0];
}

- (void)customizeAppearance
{
    UIColor *tint = [[UIColor alloc] initWithRed:0.0f/255.0f green:167.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"Whitney-Medium" size:17], NSFontAttributeName, tint,NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    UIColor *buttonTint = BUTTON_TINT_COLOR;
    NSDictionary *buttonAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                                 fontWithName:@"Whitney-Medium" size:17], NSFontAttributeName, buttonTint,NSForegroundColorAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:buttonTint];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UINavigationBar appearance].backIndicatorImage = [[UIImage imageNamed:@"navbar_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [[UIImage imageNamed:@"navbar_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
