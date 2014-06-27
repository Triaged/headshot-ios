//
//  ContactsTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "User.h"
#import "ContactsDataSource.h"
#import "ContactViewController.h"

@interface ContactsTableViewController ()

@property (nonatomic, strong) ContactsDataSource *contactsDataSource;
@property (nonatomic, strong) NSFetchedResultsController *_fetchedResultsController;

@end

@implementation ContactsTableViewController

@synthesize _fetchedResultsController, searchController;

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

    self.title = @"Contacts";
    
    [self setupTableView];
    [self fetchContacts];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchContacts) forControlEvents:UIControlEventValueChanged];

    
}


- (void)viewWillAppear:(BOOL)animated {
    // scroll the search bar off-screen
    self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.users = [User findAllExcludeCurrent];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    
    self.contactsDataSource.users = [self loadCachedUsers];

    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
  
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    searchController.delegate =  self.contactsDataSource;
    searchController.searchResultsDataSource =  self.contactsDataSource;
    searchController.searchResultsDelegate =  self;
    self.tableView.tableHeaderView = searchBar;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void) fetchContacts {
    [User usersWithCompletionHandler:^(NSArray *users, NSError *error) {
        self.contactsDataSource.users = [self loadCachedUsers];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

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
    
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:user];
    [self.navigationController pushViewController:contactVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSArray *)loadCachedUsers {
    NSArray *users = [User MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier]];
    return users;
}


@end
