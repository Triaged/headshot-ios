//
//  DepartmentContactsTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 6/12/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "DepartmentContactsTableViewController.h"
#import "User.h"
#import "ContactsDataSource.h"
#import "ContactViewController.h"

@interface DepartmentContactsTableViewController ()

@property (nonatomic, strong) ContactsDataSource *contactsDataSource;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DepartmentContactsTableViewController

- (id)initWithDepartment:(Department *)department
{
    self = [super init];
    if (self) {
        // Custom initialization
        _department = department;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = _department.name;
    [self setupTableView];
}


- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.users = [User MR_findAll];
//    self.contactsDataSource.fetchedResultsController = [self fetchedResultsController];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:user];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:contactVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
