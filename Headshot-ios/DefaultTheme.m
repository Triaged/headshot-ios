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

- (UIColor *)orangeColor
{
    return [UIColor colorWithRed:248/255.0 green:172/255.0 blue:0 alpha:1.0];
}

- (UIColor *)greenColor
{
    return [UIColor colorWithRed:0 green:167/255.0 blue:152/255.0 alpha:1.0];
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
    return [[UIColor alloc] initWithRed:248.0f/255.0f green:172.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

- (UIColor *)tableViewSeparatorColor
{
    return [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
}


- (void)customizeAppearance
{
    UIColor *tint = [[UIColor alloc] initWithRed:0.0f/255.0f green:167.0f/255.0f blue:152.0f/255.0f alpha:1.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"Whitney-Medium" size:17], NSFontAttributeName, tint,NSForegroundColorAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    UIColor *buttonTint = [self buttonTintColor];;
    NSDictionary *buttonAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                                 fontWithName:@"Whitney-Medium" size:14], NSFontAttributeName, buttonTint,NSForegroundColorAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:buttonTint];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UINavigationBar appearance].backIndicatorImage = [[UIImage imageNamed:@"navbar_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [[UIImage imageNamed:@"navbar_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
