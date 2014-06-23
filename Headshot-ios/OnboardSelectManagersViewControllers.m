//
//  OnboardSelectManagersViewControllers.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/19/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectManagersViewControllers.h"
#import "ContactCell.h"
#import "User.h"

@interface OnboardSelectManagersViewControllers ()

@end

@implementation OnboardSelectManagersViewControllers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (!self) {
        return nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTouched:)];
    self.users = [User findAllExcludeCurrent];
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [self.tableView reloadData];
}

- (void)cancelButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelSelectManagersViewController:)]) {
        [self.delegate didCancelSelectManagersViewController:self];
    }
}

#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (User *)userForIndexPath:(NSIndexPath *)indexPath
{
    return self.users[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIndentifer";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    User *user = [self userForIndexPath:indexPath];
    cell.user = user;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self userForIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(selectManagersViewController:didSelectUser:)]) {
        [self.delegate selectManagersViewController:self didSelectUser:user];
    }
}



@end
