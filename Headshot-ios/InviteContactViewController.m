//
//  InviteContactViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "InviteContactViewController.h"
#import "NSString+JAContainsSubstring.h"
#import "ContactManager.h"

@interface InviteContactViewController () <UITextFieldDelegate>

@property (assign, nonatomic) BOOL searchMode;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) NSArray *searchFilteredContacts;
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
    
    self.emailDomain = @"gmail.com";
    NSString *blacklist = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blacklist" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSArray *components = [blacklist componentsSeparatedByString:@"\n"];
    self.blackList = components;
    
    
    self.selectedContacts = [[NSMutableSet alloc] init];
    
    self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 47)];
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Invite by name, email, or phone" attributes:@{NSFontAttributeName : [ThemeManager lightFontOfSize:18], NSForegroundColorAttributeName : [[ThemeManager sharedTheme] primaryColor]}];
    self.searchField.font = [ThemeManager lightFontOfSize:18];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 5)];
    self.searchField.tintColor = [[ThemeManager sharedTheme] primaryColor];
    self.searchField.autocorrectionType = UITextAutocorrectionTypeNo;
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
    self.companyContacts = [self filterContacts:contacts byEmailDomain:self.emailDomain];
    self.companyContacts = [self sortContactsByNameOrEmail:self.companyContacts];
    _contacts = [self sortContactsByNameOrEmail:contacts];
    [self.tableView reloadData];
}

- (NSArray *)filterContacts:(NSArray *)contacts byEmailDomain:(NSString *)domain
{
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
    return companyContacts;
}

- (NSArray *)filterContacts:(NSArray *)contacts bySearchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        AddressBookContact *contact = (AddressBookContact *)evaluatedObject;
        BOOL found = [contact.fullName ja_containsSubstring:searchText];
        for (NSString *email in contact.emails) {
            found = found || [email ja_containsSubstring:searchText];
        }
        return found;
    }];
    return [contacts filteredArrayUsingPredicate:predicate];
}

- (NSArray *)sortContactsByNameOrEmail:(NSArray *)contacts
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayedTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    return [contacts sortedArrayUsingDescriptors:@[sort]];
}

- (void)inviteButtonTouched:(id)sender
{
    
}

- (AddressBookContact *)addressBookContactForIndexPath:(NSIndexPath *)indexPath
{
    AddressBookContact *contact;
    if (self.searchMode) {
        return self.searchFilteredContacts[indexPath.row];
    }
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
    if (self.searchMode) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if (self.searchMode) {
        numRows = self.searchFilteredContacts.count;
    }
    else if (section == 0) {
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor colorWithRed:234/255.0 green:235/255.0 blue:236/255.0 alpha:1.0];
    UILabel *label = [[UILabel alloc] init];
    [headerView addSubview:label];
    label.font = [ThemeManager lightFontOfSize:12];
    label.textColor = [UIColor colorWithRed:76/255.0 green:80/255.0 blue:88/255.0 alpha:1.0];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    [label sizeToFit];
    label.x = 14;
    label.bottom = headerView.height - 9;
    
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (self.searchMode) {
        title = @"Invite to Badge";
    }
    else if (section == 0) {
        title = @"Suggested Contacts";
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
        cell.textLabel.font = [ThemeManager regularFontOfSize:17];
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
- (void)searchTextChanged:(UITextField *)textfield
{
    self.searchFilteredContacts = [self filterContacts:self.contacts bySearchText:textfield.text];
    self.searchMode = textfield.text && textfield.text.length;
    [self.tableView reloadData];
    self.selectedContacts = [NSMutableSet new];
}


@end
