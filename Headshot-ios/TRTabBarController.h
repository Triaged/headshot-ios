//
//  TRTabBarController.h
//  Triage-ios
//
//  Created by Charlie White on 1/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVTabBarController.h"

@interface TRTabBarController : RDVTabBarController <RDVTabBarControllerDelegate>

- (void)selectMessagesViewController;

@end
