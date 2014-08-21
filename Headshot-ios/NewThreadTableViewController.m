//
//  NewThreadTableViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NewThreadTableViewController.h"
#import <VENTokenField.h>
#import "ContactsDataSource.h"
#import "TRSearchBar.h"

@interface NewThreadTableViewController () <VENTokenFieldDataSource, VENTokenFieldDelegate>

@property (strong, nonatomic) ContactsDataSource *contactsDataSource;
@property (strong, nonatomic) VENTokenField *tokenField;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableOrderedSet *selectedUsers;

@end

@implementation NewThreadTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"New Message";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonTouched:)];
    
    
    self.selectedUsers = [[NSMutableOrderedSet alloc] init];
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.tokenField becomeFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTableView
{
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.contactsDataSource.users = [User findAllExcludeCurrent];
    self.contactsDataSource.tableViewController = self;
    self.tableView.dataSource = self.contactsDataSource;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    self.tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
    self.tokenField.returnKeyType = UIReturnKeyNext;
    self.tokenField.maxHeight = 55;
    [self.tokenField setColorScheme:[[ThemeManager sharedTheme] orangeColor]];
    self.tokenField.placeholderText = @"Who would you like to message?";
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate =  self.contactsDataSource;
    self.searchController.searchResultsDataSource =  self.contactsDataSource;
    self.searchController.searchResultsDelegate =  self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    self.tokenField.backgroundColor = [UIColor whiteColor];
    [self.tokenField addEdge:UIRectEdgeBottom width:0.5 color:[[ThemeManager sharedTheme] tableViewSeparatorColor]];
    [self.view addSubview:self.tokenField];
    
    CGRect tableViewFrame = CGRectMake(0, self.tokenField.bottom, self.view.width, self.view.height - self.tokenField.bottom);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self.contactsDataSource;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)setAddMemberMode:(BOOL)addMemberMode
{
    [self view];
    _addMemberMode = addMemberMode;
    NSString *nextButtonTitle;
    NSString *title;
    if (_addMemberMode) {
        nextButtonTitle = @"Add";
        title = @"Add Members";
    }
    else {
        nextButtonTitle = @"Next";
        title = @"New Message";
    }
    self.navigationItem.rightBarButtonItem.title = nextButtonTitle;
    self.title = title;
}

- (void)nextButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(newThreadTableViewController:didSelectUsers:)]) {
        [self.delegate newThreadTableViewController:self didSelectUsers:self.selectedUsers.array];
    }
}

#pragma mark - Table view data source
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
    if ([self.unselectableUsers containsObject:user]) {
        return;
    }
    if (![self.selectedUsers containsObject:user]) {
        [self.selectedUsers addObject:user];
    }
    else {
        [self.selectedUsers removeObject:user];
    }
    if (self.searchBar.text && self.searchBar.text.length) {
        self.searchBar.text = nil;
        [self.contactsDataSource endSearch];
    }
    [self.tokenField reloadData];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    if ([self.selectedUsers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = [[ThemeManager sharedTheme] greenColor];
    }
    else if ([self.unselectableUsers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = [UIColor lightGrayColor];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.contactsDataSource tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

#pragma mark - Token Field Delegate
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    self.searchBar.text = text;
    if (!text || !text.length) {
        [self.contactsDataSource endSearch];
    }
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.selectedUsers removeObjectAtIndex:index];
    [tokenField reloadData];
    [self.tableView reloadData];
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    
}

- (void)tokenFieldDidReturn:(VENTokenField *)tokenField
{
    [self nextButtonTouched:nil];
}

#pragma mark - Token Field Data Source
- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    User *user = self.selectedUsers[index];
    return user.fullName;
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return self.selectedUsers.count;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    NSDictionary* info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.tableView.contentInset = UIEdgeInsetsZero;
//    }];
}




@end
