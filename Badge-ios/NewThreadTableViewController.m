//
//  NewThreadTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewThreadTableViewController.h"
#import "ContactsDataSource.h"
#import "TRSearchBar.h"

@interface NewThreadTableViewController ()

@property (strong, nonatomic) ContactsDataSource *contactsDataSource;

@end

@implementation NewThreadTableViewController


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
    self.title = @"New Message";
    
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
    
    
    TRSearchBar *searchBar = [[TRSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    searchBar.placeholder = @"Who would you like to message?";
    
    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate =  self.contactsDataSource;
    self.searchController.searchResultsDataSource =  self.contactsDataSource;
    self.searchController.searchResultsDelegate =  self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    UIView *headerView = [[UIView alloc] initWithFrame:searchBar.bounds];
    [headerView addSubview:searchBar];
    [headerView addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    if ([self.delegate respondsToSelector:@selector(newThreadTableViewController:didSelectUser:)]) {
        [self.delegate newThreadTableViewController:self didSelectUser:user];
    }
}



@end
