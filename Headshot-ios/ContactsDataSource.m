//
//  ContactsDataSource.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactsDataSource.h"
#import "ContactViewController.h"
#import "User.h"
#import "EmployeeInfo.h"
#import "ContactCell.h"

@implementation ContactsDataSource

@synthesize fetchedResultsController, tableViewController;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
   
    User *user = [self itemAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"contactCell";
    ContactCell *cell = [ tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
    if ( !cell )
    {
        cell = [ [ ContactCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
    }
    
    [cell configureForUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self itemAtIndexPath:indexPath];
    
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:user];
    self.tableViewController.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.tableViewController.navigationController pushViewController:contactVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ && identifier != %@", searchText, [AppDelegate sharedDelegate].store.currentAccount.identifier];
    [[fetchedResultsController fetchRequest] setPredicate:resultPredicate];
    [fetchedResultsController performFetch:nil];
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.tableViewController.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.tableViewController.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
    [[fetchedResultsController fetchRequest] setPredicate:predicate];
    [fetchedResultsController performFetch:nil];
    [self.tableViewController.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

@end
