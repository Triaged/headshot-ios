//
//  OnboardSelectManagersViewControllers.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/19/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnboardSelectManagersViewControllers : UITableViewController

@property (strong, nonatomic) NSArray *users;
@property (readonly) NSArray *selectedUsers;

@end
