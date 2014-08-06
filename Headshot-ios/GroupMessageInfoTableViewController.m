//
//  GroupMessageInfoTableViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/30/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "GroupMessageInfoTableViewController.h"
#import "ContactsDataSource.h"
#import "ContactCell.h"

@interface GroupMessageInfoTableViewController ()

@end

@implementation GroupMessageInfoTableViewController

- (id)initWithUsers:(NSArray *)users
{
    self = [self init];
    self.users = users;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (self.users) {
        numberOfRows = self.users.count;
    }
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (User *)userForIndexPath:(NSIndexPath *)indexPath
{
    return self.users[indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIndetifier";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-icn-profile"]];
        cell.accessoryView = accessoryView;
    }
    cell.user = [self userForIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(groupMessageInfoTableViewController:didSelectUser:)]) {
        [self.delegate groupMessageInfoTableViewController:self didSelectUser:[self userForIndexPath:indexPath]];
    }
}



@end
