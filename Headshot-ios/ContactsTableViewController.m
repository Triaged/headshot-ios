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
    //self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.fetchedResultsController = [self fetchedResultsController];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self.contactsDataSource;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
  
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    searchController.delegate =  self.contactsDataSource;
    searchController.searchResultsDataSource =  self.contactsDataSource;
    searchController.searchResultsDelegate =  self.contactsDataSource;
    self.tableView.tableHeaderView = searchBar;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void) fetchContacts {
    [User usersWithCompletionHandler:^(NSArray *users, NSError *error) {
        [[self fetchedResultsController] performFetch:nil];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
        _fetchedResultsController = [User MR_fetchAllSortedBy:nil
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self.contactsDataSource];
        
    }
    return _fetchedResultsController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
