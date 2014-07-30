//
//  NewThreadTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewThreadTableViewController.h"
#import <VENTokenField.h>
#import "ContactsDataSource.h"
#import "TRSearchBar.h"

@interface NewThreadTableViewController () <VENTokenFieldDataSource, VENTokenFieldDelegate>

@property (strong, nonatomic) ContactsDataSource *contactsDataSource;
@property (strong, nonatomic) VENTokenField *tokenField;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableOrderedSet *selectedUsers;

@end

@implementation NewThreadTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Message";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonTouched:)];
    
    [self setupTableView];
    
    self.selectedUsers = [[NSMutableOrderedSet alloc] init];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.users = [User findAllExcludeCurrent];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    self.tokenField.maxHeight = 55;
    [self.tokenField setColorScheme:[[ThemeManager sharedTheme] orangeColor]];
    self.tokenField.placeholderText = @"Who would you like to message?";
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate =  self.contactsDataSource;
    self.searchController.searchResultsDataSource =  self.contactsDataSource;
    self.searchController.searchResultsDelegate =  self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    self.tokenField.backgroundColor = [UIColor whiteColor];
    [self.tokenField addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    [self.view addSubview:self.tokenField];
    
    CGRect tableViewFrame = CGRectMake(0, self.tokenField.bottom, self.view.width, self.view.height - self.tokenField.bottom);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self.contactsDataSource;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)nextButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(newThreadTableViewController:didSelectUsers:)]) {
        [self.delegate newThreadTableViewController:self didSelectUsers:self.selectedUsers.array];
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self.contactsDataSource tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contactsDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.contactsDataSource tableView:tableView viewForHeaderInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    [self.selectedUsers addObject:user];
    [self.tokenField reloadData];
    self.searchBar.text = nil;
    [self.contactsDataSource endSearch];
//    if ([self.delegate respondsToSelector:@selector(newThreadTableViewController:didSelectUser:)]) {
//        [self.delegate newThreadTableViewController:self didSelectUser:user];
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    if ([self.selectedUsers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.contactsDataSource tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

#pragma mark - Token Field Delegate
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    self.searchBar.text = text;
    if (!text || !text.length) {
        [self.contactsDataSource endSearch];
    }
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.selectedUsers removeObjectAtIndex:index];
    [tokenField reloadData];
    [self.tableView reloadData];
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    
}

#pragma mark - Token Field Data Source
- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    User *user = self.selectedUsers[index];
    return user.fullName;
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return self.selectedUsers.count;
}




@end
