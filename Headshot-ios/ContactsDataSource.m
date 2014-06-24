//
//  ContactsDataSource.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactsDataSource.h"
#import "User.h"
#import "EmployeeInfo.h"
#import "ContactCell.h"

NSString * const Alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
@interface ContactsDataSource()

@property (strong, nonatomic) NSDictionary *userDictionary;
@property (strong, nonatomic) NSArray *filteredUsers;
@property (assign, nonatomic) BOOL searchMode;

@end

@implementation ContactsDataSource

- (id)init
{
    return [self initWithUsers:nil];
}

- (id)initWithUsers:(NSArray *)users
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.separateSectionsForNames = YES;
    self.users = users;
    return self;
}

- (void)setTableViewController:(UITableViewController *)tableViewController
{
    _tableViewController = tableViewController;
    tableViewController.tableView.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    self.filteredUsers = users;
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    _users = [_users sortedArrayUsingDescriptors:@[descriptor]];
    //sort alphabetically
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    for (User *user in users) {
        NSString *key = [user.lastName substringToIndex:1];
        NSMutableArray *usersByName = userDictionary[key];
        if (!usersByName) {
            usersByName = [[NSMutableArray alloc] init];
            userDictionary[key] = usersByName;
        }
        [usersByName addObject:user];
    }
    //sort each section alphabetically
    
    self.userDictionary = [NSDictionary dictionaryWithDictionary:userDictionary];
}

- (User *)userAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *users = [self usersInSection:indexPath.section];
    if (!users) {
        return nil;
    }
    return users[indexPath.row];
}

- (NSArray *)usersInSection:(NSInteger)section
{
    if (self.separateSectionsForNames) {
        return self.userDictionary[[Alphabet substringWithRange:NSMakeRange(section, 1)]];
    }
    return self.filteredUsers;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.separateSectionsForNames ? Alphabet.length : 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if (self.separateSectionsForNames) {
        NSArray *users = [self usersInSection:section];
        numRows = users ? users.count : 0;
    }
    else {
        numRows = self.filteredUsers.count;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (!self.separateSectionsForNames) {
        return height;
    }
    NSArray *usersInSection = [self usersInSection:section];
    if (usersInSection) {
        height = 30;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (!self.separateSectionsForNames) {
        return height;
    }
    NSArray *usersInSection = [self usersInSection:section];
    if (usersInSection) {
        height = 10;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderIdentifier = @"HeaderIdentifier";
    static NSInteger HeaderLabelTag = 1;
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:view.bounds];
        titleLabel.font = [ThemeManager boldFontOfSize:12];
        titleLabel.x = 15;
        titleLabel.tag = HeaderLabelTag;
        [view addSubview:titleLabel];
        [view addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    }
    UILabel *titleLabel = (UILabel *)[view viewWithTag:HeaderLabelTag];
    titleLabel.text = [Alphabet substringWithRange:NSMakeRange(section, 1)];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    static NSString *FooterIdentifier = @"FooterIdentifier";
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:FooterIdentifier];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForFooterInSection:section])];
        view.backgroundColor = [UIColor clearColor];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
   
    User *user = [self userAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"contactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.user = user;
    return cell;
}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.separateSectionsForNames = NO;
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"fullName contains[c] %@ && identifier != %@", searchText, [AppDelegate sharedDelegate].store.currentAccount.identifier];
    self.filteredUsers = [self.users filteredArrayUsingPredicate:resultPredicate];
    [self.tableViewController.tableView reloadData];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.tableViewController.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.tableViewController.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.separateSectionsForNames = YES;
    self.filteredUsers = self.users;
    [self.tableViewController.tableView reloadData];
}

@end
