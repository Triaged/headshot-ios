//
//  InviteContactViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "InviteContactViewController.h"
#import "ContactManager.h"

@interface InviteContactViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) NSArray *companyContacts;
@property (strong, nonatomic) NSArray *blackList;
@property (strong, nonatomic) NSString *emailDomain;
@property (strong, nonatomic) NSMutableSet *selectedContacts;

@end

@implementation InviteContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Invite Coworkers";
    
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleDone target:self action:@selector(inviteButtonTouched:)];
    self.navigationItem.rightBarButtonItem = inviteButton;
    
    self.emailDomain = @"badge.co";
    NSString *blacklist = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blacklist" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSArray *components = [blacklist componentsSeparatedByString:@"\n"];
    self.blackList = components;
    
    
    self.selectedContacts = [[NSMutableSet alloc] init];
    
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 47)];
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Invite by name, email, or phone" attributes:@{NSFontAttributeName : [ThemeManager lightFontOfSize:18], NSForegroundColorAttributeName : [[ThemeManager sharedTheme] primaryColor]}];
    self.searchField.font = [ThemeManager lightFontOfSize:18];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 5)];
    self.searchField.tintColor = [[ThemeManager sharedTheme] primaryColor];
    self.searchField.leftView = leftView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    self.searchField.delegate = self;
    [self.searchField addTarget:self
                  action:@selector(searchTextChanged:)
        forControlEvents:UIControlEventEditingChanged];
    self.tableView.tableHeaderView = self.searchField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ContactManager sharedManager] requestContactPermissions:^{
        [[ContactManager sharedManager] fetchAddressBookContacts:^(NSArray *contacts) {
            self.contacts = contacts;
        } failure:nil];
    } failure:^(NSError *error) {
        
    }];
}

- (void)setContacts:(NSArray *)contacts
{
    _contacts = contacts;
    NSMutableArray *companyContacts = [[NSMutableArray alloc] init];
    for (AddressBookContact *contact in contacts) {
        if (contact.emails) {
            for (NSString *email in contact.emails) {
                if ([email rangeOfString:self.emailDomain].location != NSNotFound) {
                    [companyContacts addObject:contact];
                }
            }
        }
    }
    self.companyContacts = [NSArray arrayWithArray:companyContacts];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [self.companyContacts sortedArrayUsingDescriptors:@[sort]];
    _contacts = [contacts sortedArrayUsingDescriptors:@[sort]];
    [self.tableView reloadData];
}

- (void)inviteButtonTouched:(id)sender
{
    
}

- (AddressBookContact *)addressBookContactForIndexPath:(NSIndexPath *)indexPath
{
    AddressBookContact *contact;
    if (indexPath.section == 0) {
        contact = self.companyContacts[indexPath.row];
    }
    else if (indexPath.section == 1) {
        contact = self.contacts[indexPath.row];
    }
    return contact;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 49;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if (section == 0) {
        numRows = self.companyContacts.count;
    }
    else {
        numRows = self.contacts.count;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 0) {
        title = self.emailDomain;
    }
    else {
        title = @"All Contacts";
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [ThemeManager lightFontOfSize:17];
        cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
        cell.detailTextLabel.font = [ThemeManager lightFontOfSize:13];
        cell.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
        UIImage *inviteButtonImage = [UIImage imageNamed:@"invite-add"];
        UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectedButton.size = inviteButtonImage.size;
        [selectedButton setImage:inviteButtonImage forState:UIControlStateNormal];
        [selectedButton setImage:[UIImage imageNamed:@"invite-added"] forState:UIControlStateSelected];
        selectedButton.userInteractionEnabled = NO;
        cell.accessoryView = selectedButton;
    }
    AddressBookContact *contact = [self addressBookContactForIndexPath:indexPath];
    if (contact.emails.count) {
        cell.detailTextLabel.text = [contact.emails firstObject];
    }
    else if (contact.phoneNumbers.count) {
        cell.detailTextLabel.text = [contact.phoneNumbers firstObject];
    }
    cell.textLabel.text = [self addressBookContactForIndexPath:indexPath].fullName;
    UIButton *selectedButton = (UIButton *)cell.accessoryView;
    selectedButton.selected = [self.selectedContacts containsObject:contact];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressBookContact *contact = [self addressBookContactForIndexPath:indexPath];
    if ([self.selectedContacts containsObject:contact]) {
        [self.selectedContacts removeObject:contact];
    }
    else {
        [self.selectedContacts addObject:contact];
    }
    [self.tableView reloadData];
}

#pragma mark - search text
- (void)searchTextChanged:(id)textfield
{
    [self.tableView reloadData];
    self.selectedContacts = [NSMutableSet new];
}


@end
