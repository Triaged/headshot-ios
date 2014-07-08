//
//  OnboardSelectDepartmentViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/18/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Department.h"

@class OnboardSelectDepartmentViewController;
@protocol OnboardSelectDepartmentViewControllerDelegate <NSObject>

- (void)didCancelSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController;
- (void)OnboardSelectDepartmentViewController:(OnboardSelectDepartmentViewController *)selectDepartmentViewController didSelectDepartment:(Department *)department;

@end

@interface OnboardSelectDepartmentViewController : UITableViewController

@property (strong, nonatomic) NSArray *departments;
@property (weak, nonatomic) id<OnboardSelectDepartmentViewControllerDelegate> delegate;

@end
