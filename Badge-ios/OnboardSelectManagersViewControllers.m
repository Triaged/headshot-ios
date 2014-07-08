//
//  OnboardSelectManagersViewControllers.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/19/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectManagersViewControllers.h"
#import "ContactsDataSource.h"
#import "ContactCell.h"
#import "User.h"

@interface OnboardSelectManagersViewControllers ()

@property (strong, nonatomic) ContactsDataSource *contactsDataSource;
@property (strong, nonatomic) UISearchDisplayController *searchController;

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
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setupTableView];
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.users = [User findAllExcludeCurrent];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:searchBar contentsController:self];
    self.searchController.delegate =  self.contactsDataSource;
    self.searchController.searchResultsDataSource =  self.contactsDataSource;
    self.searchController.searchResultsDelegate =  self;
    self.tableView.tableHeaderView = searchBar;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)cancelButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelSelectManagersViewController:)]) {
        [self.delegate didCancelSelectManagersViewController:self];
    }
}

#pragma mark - UITableView Data Source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contactsDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self.contactsDataSource tableView:tableView heightForHeaderInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.contactsDataSource tableView:tableView viewForHeaderInSection:section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(selectManagersViewController:didSelectUser:)]) {
        [self.delegate selectManagersViewController:self didSelectUser:user];
    }
}



@end
