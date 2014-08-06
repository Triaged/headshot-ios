//
//  TRSearchBar.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRSearchBar.h"
#import "UIImage+SolidColor.h"

@implementation TRSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.tintColor = [[ThemeManager sharedTheme] orangeColor];
    [self setImage:[[UIImage alloc] init] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, frame.size.height)] forState:UIControlStateNormal];
    self.searchBarStyle = UISearchBarStyleMinimal;
    self.backgroundColor = [UIColor whiteColor];
    [[UITextField appearanceWhenContainedIn:[TRSearchBar class], nil] setFont:[ThemeManager regularFontOfSize:14]];
    return self;
}

@end
