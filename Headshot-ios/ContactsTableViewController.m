//
//  ContactsTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "User.h"
#import "TagSetItem.h"
#import "ContactsDataSource.h"
#import "ContactViewController.h"
#import "ContactsContainerViewController.h"

@interface ContactsTableViewController ()

@property (nonatomic, strong) ContactsDataSource *contactsDataSource;
@property (nonatomic, strong) NSFetchedResultsController *_fetchedResultsController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) float verticalContentOffset;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearContacts)
                                                 name:@"signout"
                                               object:nil];

    
    [self setupTableView];
    [self fetchContacts];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchContacts) forControlEvents:UIControlEventValueChanged];

}


- (void)viewWillAppear:(BOOL)animated {
    // scroll the search bar off-screen
    self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    self.navigationController.navigationBar.shadowImage = nil;
    
    // If maintaining scroll view position
    if (_verticalContentOffset >= 44.0) {
        [self.tableView setContentOffset:CGPointMake(0, _verticalContentOffset)];
    }

    
}

-(void)viewWillDisappear:(BOOL)animated {
    [searchController setActive:NO animated:NO];
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    [self loadUsers];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    
    searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:_searchBar contentsController:self];
    searchController.delegate =  self.contactsDataSource;
    searchController.searchResultsDataSource =  self.contactsDataSource;
    searchController.searchResultsDelegate =  self;
    self.tableView.tableHeaderView = _searchBar;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
}

- (void)setTagSetItems:(NSSet *)tagSetItems
{
    _tagSetItems = tagSetItems;
    NSSortDescriptor *prioritySort = [NSSortDescriptor sortDescriptorWithKey:@"tagSet.priority" ascending:NO];
    TagSetItem *first = [[tagSetItems sortedArrayUsingDescriptors:@[prioritySort]] firstObject];
    self.navigationItem.title = first.name;
}

- (void)loadUsers
{
    NSArray *users = self.tagSetItems ? [User findAllIntersectingfItems:self.tagSetItems.allObjects excludeCurrent:YES] : [User findAllExcludeCurrent] ;
    self.contactsDataSource.users = users;
}

- (void) fetchContacts {
    [User usersWithCompletionHandler:^(NSArray *users, NSError *error) {
        [self loadUsers];
        UITableView *tableView = self.containerViewController ? self.containerViewController.tableView : self.tableView;
        [tableView reloadData];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.contactsDataSource tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    
    if ([self.contactsTableViewControllerDelegate respondsToSelector:@selector(contactsTableViewController:didSelectContact:)]) {
        [self.contactsTableViewControllerDelegate contactsTableViewController:self didSelectContact:user];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.containerViewController.navigationController setNavigationBarHidden:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.containerViewController.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

    
-(void)clearContacts {
    self.contactsDataSource.users = nil;
    [self.tableView reloadData];
}




@end
