//
//  DepartmentContactsTableViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 6/12/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Department.h"

@interface DepartmentContactsTableViewController : UITableViewController <UITableViewDelegate>

@property (nonatomic, strong) Department *department;

- (id)initWithDepartment:(Department *)department;

@end
