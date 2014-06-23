//
//  OnboardSelectManagersViewControllers.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/19/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class OnboardSelectManagersViewControllers;
@protocol SelectManagersViewControllerDelegate <NSObject>

- (void)selectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController didSelectUser:(User *)user;
- (void)didCancelSelectManagersViewController:(OnboardSelectManagersViewControllers *)selectManagersViewController;

@end

@interface OnboardSelectManagersViewControllers : UITableViewController

@property (strong, nonatomic) NSArray *users;
@property (weak, nonatomic) id<SelectManagersViewControllerDelegate>delegate;

@end
