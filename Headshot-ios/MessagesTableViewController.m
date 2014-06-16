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
#import "MessageThreadPreviewCell.h"

@interface MessagesTableViewController ()

@end

@implementation MessagesTableViewController

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
    
    self.title = @"Inbox";
    
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"NEW" style:UIBarButtonItemStylePlain target:self action:@selector(newThread)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.messageThreads = [MessageThread MR_findAll];
}

- (void)newThread
{
    NewThreadTableViewController *newThreadVC = [[NewThreadTableViewController alloc] init];
    newThreadVC.messagesTableVC = self;
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissModal)];
    newThreadVC.navigationItem.leftBarButtonItem = cancelButtonItem;
    TRNavigationController *nav = [[TRNavigationController alloc] initWithRootViewController:newThreadVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismissModal
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createOrFindThreadForRecipient:(User *)recipient
{
    
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
    self.tableView.tableFooterView = [[UIView alloc] init];
}


- (void)setMessageThreads:(NSArray *)messageThreads
{
    _messageThreads = messageThreads;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (MessageThread *)threadAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messageThreads[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return self.messageThreads.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    MessageThread *thread = [self threadAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"messageThreadCell";
    MessageThreadPreviewCell *cell = [ tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
    if ( !cell )
    {
        cell = [[MessageThreadPreviewCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.messageThread = thread;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageThread *thread = [self threadAtIndexPath:indexPath];
    
    MessageThreadViewController *messageThreadVC = [[MessageThreadViewController alloc] initWithMessageThread:thread];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:messageThreadVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
