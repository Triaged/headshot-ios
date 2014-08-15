//
//  OnboardJobViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnboardNavigationController.h"
#import "User.h"

@interface OnboardJobViewController : UITableViewController <OnboardViewController>

@property (strong, nonatomic) User *user;


@end
