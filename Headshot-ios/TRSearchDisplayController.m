//
//  TRSearchDisplayController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRSearchDisplayController.h"

@implementation TRSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive:visible animated: animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}


@end
