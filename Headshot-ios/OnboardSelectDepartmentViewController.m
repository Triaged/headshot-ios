//
//  OnboardSelectDepartmentViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/18/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectDepartmentViewController.h"

@interface OnboardSelectDepartmentViewController ()

@end

@implementation OnboardSelectDepartmentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Department";
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.departments.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [ThemeManager regularFontOfSize:18];
    }
    if (indexPath.row < self.departments.count) {
        Department *department = self.departments[indexPath.row];
        cell.textLabel.text = department.name;
        cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    }
    else {
        cell.textLabel.text = @"Add New Department";
        cell.textLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.departments.count - 1) {
        Department *department = self.departments[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(OnboardSelectDepartmentViewController:didSelectDepartment:)]) {
            [self.delegate OnboardSelectDepartmentViewController:self didSelectDepartment:department];
        }
    }
    else {
        [self addDepartmentSelected];
    }
}

- (void)addDepartmentSelected
{
    Department *department = [Department MR_createEntity];
    department.name = @"Test Department";
    [department postWithSuccess:^(Department *department) {
        
    } failure:^(NSError *error) {
        
    }];
}

@end
