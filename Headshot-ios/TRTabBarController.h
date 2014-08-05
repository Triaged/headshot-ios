//
//  TRTabBarController.h
//  Triage-ios
//
//  Created by Charlie White on 1/22/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesTableViewController.h"
#import "MessageNavigationController.h"

@interface TRTabBarController : UITabBarController

@property (strong, nonatomic) MessagesTableViewController *messagesTableViewController;
@property (strong, nonatomic) MessageNavigationController *messageNavigationController;
- (void)selectMessagesViewController;


@end
