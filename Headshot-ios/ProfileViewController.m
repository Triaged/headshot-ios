//
//  ProfileViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ProfileViewController.h"
#import "EmployeeInfo.h"
#import "TagSetItem.h"
#import "TagSet.h"
#import "TRAvatarImageView.h"
#import "MailComposer.h"
#import "MessageThreadViewController.h"
#import "ContactsTableViewController.h"

@interface ProfileItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) UIImage *accessoryImage;
@property (copy) void (^selectionBlock)(void);

- (instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail accessoryImage:(UIImage *)image selectionBlock:(void (^)())selectionBlock;

@end

@interface ProfileViewController() <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *profileItems;
@property (strong, nonatomic) TRAvatarImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *positionLabel;
@property (strong, nonatomic) UIButton *sendMessageButton;

@end

@implementation ProfileViewController

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        self.user = user;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:229/255.0 alpha:1.0];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 160)];
    self.tableView.tableHeaderView = headerView;
    
    self.avatarImageView = [[TRAvatarImageView alloc] init];
    [headerView addSubview:self.avatarImageView];
    self.avatarImageView.size = CGSizeMake(74, 74);
    self.avatarImageView.x = 20;
    self.avatarImageView.y = 19;
    
    self.nameLabel = [[UILabel alloc] init];
    [headerView addSubview:self.nameLabel];
    self.nameLabel.font = [ThemeManager lightFontOfSize:29];
    self.nameLabel.numberOfLines = 0;
    
    self.positionLabel = [[UILabel alloc] init];
    [headerView addSubview:self.positionLabel];
    self.positionLabel.font = [ThemeManager lightFontOfSize:16];
    self.positionLabel.textColor = [UIColor colorWithRed:155/255.0 green:160/255.0 blue:169/255.0 alpha:1.0];
    
    self.sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.sendMessageButton];
    self.sendMessageButton.size = CGSizeMake(self.view.width, 44);
    self.sendMessageButton.bottom = self.view.height;
    self.sendMessageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.sendMessageButton setTitle:@"Send Message" forState:UIControlStateNormal];
    self.sendMessageButton.titleLabel.font = [ThemeManager regularFontOfSize:16];
    [self.sendMessageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendMessageButton.backgroundColor = [[ThemeManager sharedTheme] primaryColor];
    [self.sendMessageButton addTarget:self action:@selector(messageButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.sendMessageButton.height, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.user) {
        [self reloadData];
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self reloadData];
}

- (void)reloadData
{
    self.avatarImageView.user = self.user;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n%@", self.user.firstName, self.user.lastName];
    self.nameLabel.x = self.avatarImageView.right + 21;
    self.nameLabel.width = self.view.width - self.nameLabel.x;
    [self.nameLabel sizeToFit];
    self.nameLabel.y = self.avatarImageView.y;
    
    self.positionLabel.text = self.user.employeeInfo.jobTitle;
    self.positionLabel.x = self.nameLabel.x;
    self.positionLabel.width = self.nameLabel.width;
    [self.positionLabel sizeToFit];
    self.positionLabel.y = self.avatarImageView.bottom + 6;
    
    
    NSMutableArray *profileItems = [[NSMutableArray alloc] init];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"tagSet.priority" ascending:YES];
    NSArray *tagSetItems = [self.user.tagSetItems sortedArrayUsingDescriptors:@[sort]];
    for (TagSetItem *tagItem in tagSetItems) {
//        tag names are currently plural. Make singular assuming removing the 's' at the end of the name works
        NSString *title = tagItem.tagSet.name;
        if ([[title substringWithRange:NSMakeRange(title.length - 1, 1)] isEqualToString:@"s"]) {
            title = [title substringWithRange:NSMakeRange(0, title.length - 1)];
        }
        ProfileItem *profileItem = [[ProfileItem alloc] initWithTitle:title detail:tagItem.name accessoryImage:nil selectionBlock:^{
            [self showContactsForTagSetItem:tagItem];
        }];
        [profileItems addObject:profileItem];
    }
    
    ProfileItem *emailItem = [[ProfileItem alloc] initWithTitle:@"Email" detail:self.user.email accessoryImage:[UIImage imageNamed:@"profile-icn-email"] selectionBlock:^{
        [self sendEmailToAddress:self.user.email];
    }];
    [profileItems addObject:emailItem];
    
    NSString *cellPhone = self.user.employeeInfo.cellPhone;
    if (cellPhone) {
        ProfileItem *cellPhoneItem = [[ProfileItem alloc] initWithTitle:@"Mobile" detail:cellPhone accessoryImage:[UIImage imageNamed:@"profile-icn-phone"] selectionBlock:^{
            [self callPhoneNumber:cellPhone];
        }];
        [profileItems addObject:cellPhoneItem];
    }
    
    NSString *officePhone = self.user.employeeInfo.officePhone;
    if (officePhone) {
        ProfileItem *officePhoneItem = [[ProfileItem alloc] initWithTitle:@"Office" detail:officePhone accessoryImage:[UIImage imageNamed:@"profile-icn-phone"] selectionBlock:^{
            [self callPhoneNumber:officePhone];
        }];
        [profileItems addObject:officePhoneItem];
    }
    
    self.profileItems = [NSArray arrayWithArray:profileItems];
    
    [self.tableView reloadData];
}

- (void)sendEmailToAddress:(NSString *)emailAddress
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [MailComposer sharedComposer];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[emailAddress]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (void)callPhoneNumber:(NSString *)phoneNumber
{
    NSString *urlString = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)messageButtonTouched
{
    BOOL pop = NO;
    if (self.backViewController && [self.backViewController isKindOfClass:[MessageThreadViewController class]]) {
        MessageThreadViewController *messageThreadViewController = (MessageThreadViewController *)self.backViewController;
        User *recipient = [messageThreadViewController.messageThread.recipientsExcludeUser anyObject];
        pop = [recipient.identifier isEqual:self.user.identifier];
    }
    if (pop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        MessageThreadViewController *threadVC = [[MessageThreadViewController alloc] initWithRecipients:@[self.user]];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:threadVC animated:YES];
    }
}

- (void)showContactsForTagSetItem:(TagSetItem *)tagSetItem
{
    NSMutableSet *tagSetItems = [[NSMutableSet alloc] init];
    [tagSetItems addObject:tagSetItem];
    for (TagSetItem *otherItem in self.user.tagSetItems) {
        if (otherItem.tagSet.priority.integerValue < tagSetItem.tagSet.priority.integerValue) {
            [tagSetItems addObject:tagSetItem];
        }
    }
    ContactsTableViewController *contactsViewController = [[ContactsTableViewController alloc] init];
    contactsViewController.tagSetItems = tagSetItems;
    [self.navigationController pushViewController:contactsViewController animated:YES];
}

- (ProfileItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    return self.profileItems[indexPath.row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.profileItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.font = [ThemeManager regularFontOfSize:17];
        cell.textLabel.font = [ThemeManager regularFontOfSize:13];
        cell.textLabel.textColor = [[ThemeManager sharedTheme] primaryColor];
        UIImageView *accessoryImageView = [[UIImageView alloc] init];
        cell.accessoryView = accessoryImageView;
    }
    ProfileItem *item = [self itemForIndexPath:indexPath];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.detail;
    UIImageView *accessoryImageView = (UIImageView *)cell.accessoryView;
    UIImage *accessoryImage = item.accessoryImage;
    accessoryImageView.image = accessoryImage;
    if (accessoryImage) {
        accessoryImageView.size = accessoryImage.size;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProfileItem *item = [self itemForIndexPath:indexPath];
    if (item.selectionBlock) {
        item.selectionBlock();
    }
}


@end

@implementation ProfileItem

- (instancetype)initWithTitle:(NSString *)title detail:(NSString *)detail accessoryImage:(UIImage *)image selectionBlock:(void (^)())selectionBlock
{
    self = [super init];
    if (self) {
        self.title = title;
        self.detail = detail;
        self.accessoryImage = image;
        self.selectionBlock = selectionBlock;
    }
    return self;
}
@end
