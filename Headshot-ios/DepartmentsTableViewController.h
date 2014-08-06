//
//  DepartmentsTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Department.h"

@class DepartmentsTableViewController;
@protocol DepartmentsTableViewControllerDelegate <NSObject>

- (void)departmentsTableViewController:(DepartmentsTableViewController *)departmentsTableViewController didSelectDepartment:(Department *)department;

@end

@interface DepartmentsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id<DepartmentsTableViewControllerDelegate> departmentsTableViewControllerDelegate;

@end
