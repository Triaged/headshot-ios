//
//  DepartmentsTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "DepartmentsTableViewController.h"
#import "Department.h"
#import "DepartmentContactsTableViewController.h"
#import "DepartmentCell.h"

@interface DepartmentsTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DepartmentsTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchDepartments) forControlEvents:UIControlEventValueChanged];

    
    [self fetchDepartments];
}

- (void) fetchDepartments {
    [Department departmentsWithCompletionHandler:^(NSArray *departments, NSError *error) {
        _fetchedResultsController = nil;
        [[self fetchedResultsController] performFetch:nil];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"usersCount > 0"];
        _fetchedResultsController = [Department MR_fetchAllSortedBy:nil
                                                    ascending:NO
                                                withPredicate:predicate
                                                      groupBy:nil
                                                     delegate:self];
        
    }
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Department *dept = [self itemAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"departmentCell";
    DepartmentCell *cell = [ tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
    if ( !cell )
    {
        cell = [ [ DepartmentCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
    }
    
    [cell configureForDepartment:dept];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Department *dept = [self itemAtIndexPath:indexPath];
    DepartmentContactsTableViewController *deptContactsTableVC = [[DepartmentContactsTableViewController alloc] initWithDepartment:dept];
    [self.navigationController pushViewController:deptContactsTableVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}


@end
