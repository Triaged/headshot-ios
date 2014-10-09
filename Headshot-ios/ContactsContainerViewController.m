//
//  ContactsContainerViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactsContainerViewController.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>
#import "DepartmentsTableViewController.h"
#import "ContactsTableViewController.h"
#import "DepartmentContactsTableViewController.h"
#import "TRSearchDisplayController.h"
#import "ContactViewController.h"
#import "InviteContactViewController.h"

#import "TagSetTableViewController.h"

@interface ContactsContainerViewController () <ContactsTableViewControllerDelegate, DepartmentsTableViewControllerDelegate, TagSetTableViewControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UIBarButtonItem *searchButtonItem;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UITableViewController *selectedTableViewController;
@property (strong, nonatomic) TRSearchDisplayController *searchController;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation ContactsContainerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contactsViewController = [[ContactsTableViewController alloc] init];
        self.contactsViewController.containerViewController = self;
        self.contactsViewController.contactsTableViewControllerDelegate = self;
        
        self.departmentsViewController = [[TagSetTableViewController alloc] init];
        self.departmentsViewController.delegate = self;
        
        self.viewControllers = @[self.contactsViewController, self.departmentsViewController];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
    
    self.searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTouched:)];
    self.searchButtonItem.tintColor = [[ThemeManager sharedTheme] orangeColor];
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(inviteButtonTouched:)];
    self.navigationItem.rightBarButtonItems = @[inviteButton, self.searchButtonItem];
    
    UIBarButtonItem *settingsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:nil];
//    self.navigationItem.leftBarButtonItem = settingsButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.departmentsViewController.departmentsTableViewControllerDelegate = self;
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.placeholder = @"Search                                                              ";
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    self.searchController = [[TRSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:[AppDelegate sharedDelegate].window.rootViewController];
    self.searchController.delegate = (id<UISearchDisplayDelegate>)self.contactsViewController.tableView.dataSource;
    self.searchController.searchResultsDelegate = self.contactsViewController.tableView.delegate;
    self.searchController.searchResultsDataSource = self.contactsViewController.tableView.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.departmentsViewController.tagSet) {
            self.departmentsViewController.tagSet = [TagSet MR_findFirstOrderedByAttribute:@"priority" ascending:YES];
    }
    [[AppDelegate sharedDelegate].window.rootViewController.view addSubview:self.searchBar];
    [self setSearchBarHidden:YES animated:NO completion:nil];
    
    [self updateSegmentedControl];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self selectViewControllerWithIndex:self.segmentedControl.selectedSegmentIndex];
}

- (void)updateSegmentedControl
{
    if (self.tagsHidden) {
        self.tableView.tableHeaderView = nil;
        return;
    }
    TagSet *tagSet = self.departmentsViewController.tagSet;
    UIView *headerView;
    if (tagSet) {
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Contacts", tagSet.name]];
        self.segmentedControl.tintColor = [[ThemeManager sharedTheme] primaryColor];
        [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:self.segmentedControl];
        self.tableView.tableHeaderView = headerView;
        self.segmentedControl.width = 200;
        self.segmentedControl.centerX = headerView.width/2.0;
        self.segmentedControl.centerY = headerView.height/2.0;
    }
    self.tableView.tableHeaderView = headerView;
}

- (void)inviteButtonTouched:(id)sender
{
    InviteContactViewController *inviteViewController = [[InviteContactViewController alloc] init];
    TRNavigationController *navigationController = [[TRNavigationController alloc] initWithRootViewController:inviteViewController];
    inviteViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    __weak typeof(self) weakSelf = self;
    [self setSearchBarHidden:YES animated:YES completion:^(BOOL finished) {
        [weakSelf.searchBar removeFromSuperview];
    }];
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl
{
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    [self selectViewControllerWithIndex:selectedIndex];
}

- (void)selectViewControllerWithIndex:(NSInteger)index
{
    self.selectedTableViewController = self.viewControllers[index];
    self.tableView.delegate = self.selectedTableViewController.tableView.delegate;
    self.tableView.dataSource = self.selectedTableViewController.tableView.dataSource;
    self.refreshControl = self.selectedTableViewController.refreshControl;
    self.tableView.separatorStyle = self.selectedTableViewController.tableView.separatorStyle;
    self.tableView.tableFooterView = self.selectedTableViewController.tableView.tableFooterView;
    [self.tableView reloadData];
}

- (void)searchButtonTouched:(id)sender
{
    [self.searchBar becomeFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self setSearchBarHidden:NO animated:YES completion:nil];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (!self.searchBar.text || !self.searchBar.text.length) {
        [self setSearchBarHidden:YES animated:YES completion:nil];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setSearchBarHidden:YES animated:YES completion:nil];
    [self.searchBar resignFirstResponder];
}

- (void)setSearchBarHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    NSTimeInterval duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.searchBar.y = hidden ? -self.searchBar.height : 16;
    } completion:completion];
}

- (void)contactsTableViewController:(ContactsTableViewController *)contactsTableViewController didSelectContact:(User *)user
{
    [self.searchBar endEditing:YES];
    [self.searchController setActive:NO animated:YES];
    ContactViewController *contactViewController = [[ContactViewController alloc] initWitUser:user];
    [self.navigationController pushViewController:contactViewController animated:YES];
}

- (void)departmentsTableViewController:(DepartmentsTableViewController *)departmentsTableViewController didSelectDepartment:(Department *)department
{
    [self.searchBar endEditing:YES];
    [self.searchController setActive:NO animated:YES];
    DepartmentContactsTableViewController *deptContactsTableVC = [[DepartmentContactsTableViewController alloc] initWithDepartment:department];
    [self.navigationController pushViewController:deptContactsTableVC animated:YES];
}

- (void)tagSetTableViewController:(TagSetTableViewController *)tagSetTableViewController didSelectTagSetItem:(TagSetItem *)tagSetItem
{
    ContactsContainerViewController *containerViewController = [[ContactsContainerViewController alloc] init];
    TagSet *tagSet = [TagSet MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"priority > %@", self.departmentsViewController.tagSet.priority] sortedBy:@"priority" ascending:YES];
    containerViewController.departmentsViewController.tagSet = tagSet;
    if (!tagSet) {
        containerViewController.tagsHidden = YES;
    }
    NSMutableSet *tagSetItems = [[NSMutableSet alloc] initWithObjects:tagSetItem, nil];
    if (self.contactsViewController.tagSetItems) {
        [tagSetItems addObjectsFromArray:self.contactsViewController.tagSetItems.allObjects];
    }
    [tagSetItems addObject:tagSetItem];
    containerViewController.contactsViewController.tagSetItems = tagSetItems;
    containerViewController.departmentsViewController.previousTagSetItems = tagSetItems;
    
    [self.navigationController pushViewController:containerViewController animated:YES];
}

@end
