//
//  MessagesTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "MessageThread.h"
#import "User.h"
#import "MessageThreadViewController.h"
#import "NewThreadTableViewController.h"

@interface MessagesTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *_fetchedResultsController;

@end

@implementation MessagesTableViewController

@synthesize _fetchedResultsController;

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
    
    self.title = @"Messages";
    
    [self setupTableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newThread)];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:NO animated:YES];
}

- (void)newThread {
    NewThreadTableViewController *newThreadVC = [[NewThreadTableViewController alloc] init];
    newThreadVC.messagesTableVC = self;
    TRNavigationController *nav = [[TRNavigationController alloc] initWithRootViewController:newThreadVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    

//    
//    [self.tableView reloadData];
}

-(void)createOrFindThreadForRecipient:(User *)recipient {
    
    MessageThread *thread = [MessageThread MR_findFirstByAttribute:@"recipient" withValue:recipient];
    if (thread == nil) {
        
        thread = [MessageThread MR_createEntity];
        thread.lastMessageTimeStamp = [NSDate date];
        thread.recipient = recipient;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    
    MessageThreadViewController *messageThreadVC = [[MessageThreadViewController alloc] initWithMessageThread:thread];
    [self.navigationController pushViewController:messageThreadVC animated:YES];
}

- (void)setupTableView
{
  
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        _fetchedResultsController = [MessageThread MR_fetchAllSortedBy:@"lastMessageTimeStamp"
                                                    ascending:NO
                                                withPredicate:nil
                                                      groupBy:nil
                                                     delegate:self];
        
    }
    return _fetchedResultsController;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self fetchedResultsController] objectAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    MessageThread *thread = [self itemAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"messageThreadCell";
    UITableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
    if ( !cell )
    {
        cell = [ [ UITableViewCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
    }
    
    cell.textLabel.text = thread.recipient.name;
    NSURL *avatarUrl = [NSURL URLWithString:thread.recipient.avatarFaceUrl];
    [cell.imageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageThread *thread = [self itemAtIndexPath:indexPath];
    
    MessageThreadViewController *messageThreadVC = [[MessageThreadViewController alloc] initWithMessageThread:thread];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:messageThreadVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
