//
//  ContactViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactViewController.h"
#import <BlocksKit+UIKit.h>
#import "EmployeeInfo.h"
#import "OfficeLocation.h"
#import "MessageThreadViewController.h"
#import "ContactDetailsDataSource.h"
#import "MailComposer.h"


@interface ContactViewController ()

@property (nonatomic, strong) ContactDetailsDataSource *contactDetailsDataSource;

@end

@implementation ContactViewController

@synthesize avatarImageView, nameLabel, titleLabel;

- (id)initWitUser:(User *)theUser
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = theUser;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Set the background and shadow image to get rid of the line.
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    _scrollView.delegate = self;
    
    [self refreshUser];
}

- (void) refreshUser {
    [self.user updateWithCompletionHandler:^(User *user, NSError *error) {
        if (!error) {
            self.user = user;
            [self loadViewFromData];
        }
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self loadViewFromData];
}

-(void) viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.shadowImage = nil;
}

-(void)loadViewFromData {
    NSURL *avatarUrl = [NSURL URLWithString:self.user.avatarFaceUrl];
    avatarImageView.user = self.user;
    
    self.nameLabel.text = self.user.fullName;
    self.titleLabel.text = self.user.employeeInfo.jobTitle;
    self.currentOfficeLocationLabel.text = self.user.currentOfficeLocation.streetAddress;
    
    self.contactDetailsDataSource = [[ContactDetailsDataSource alloc] initWithUser:self.user];
    self.contactDetailsDataSource.contactVC = self;
    self.contactDetailsTableView.dataSource = self.contactDetailsDataSource;
    self.contactDetailsTableView.delegate = self.contactDetailsDataSource;
    self.contactDetailsTableView.scrollEnabled = NO;
    self.contactDetailsTableView.contentInset =  UIEdgeInsetsMake(0, 0, 20, 0);
    self.contactDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contactDetailsTableView registerNib:[UINib nibWithNibName:@"ContactInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactInfoCell"];
    [self.contactDetailsTableView reloadData];
    
    if (!self.user.employeeInfo.hasPhoneNumber) {
        self.callButton.enabled = NO;
        self.callLabel.textColor = [[ThemeManager sharedTheme] disabledGrayTextColor];
    }

}

-(void)viewDidLayoutSubviews
{
    [self.contactDetailsTableView reloadData];
    self.tableHeightConstraint.constant = self.contactDetailsTableView.contentSize.height;
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageTapped:(id)sender {
    BOOL pop = NO;
    if (self.backViewController && [self.backViewController isKindOfClass:[MessageThreadViewController class]]) {
        MessageThreadViewController *messageThreadViewController = (MessageThreadViewController *)self.backViewController;
        User *recipient = [messageThreadViewController.messageThread.recipients anyObject];
        pop = [recipient.identifier isEqual:self.user.identifier];
    }
    if (pop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        MessageThreadViewController *threadVC = [[MessageThreadViewController alloc] initWithRecipient:self.user];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:threadVC animated:YES];
    }
    [[AnalyticsManager sharedManager] profileButtonTouched:@"message"];
}

- (IBAction)emailTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [MailComposer sharedComposer];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[self.user.email]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    [[AnalyticsManager sharedManager] profileButtonTouched:@"email"];
}

- (IBAction)meetTapped:(id)sender {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                // display error message here
            }
            else if (!granted)
            {
                // display access denied error message here
            }
            else
            {
                // access granted
                EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
                controller.eventStore = store;
                controller.editViewDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];
            }
        });
    }];
}

- (IBAction)callTapped:(id)sender {
    
    if (self.user.employeeInfo.cellPhone && self.user.employeeInfo.officePhone) {
        [self callCellOrOffice];
    } else if (self.user.employeeInfo.cellPhone) {
        [self callCellPhone];
    } else if (self.user.employeeInfo.officePhone) {
        [self callOfficePhone];
           }
    [[AnalyticsManager sharedManager] profileButtonTouched:@"phone"];
}

- (void) callCellOrOffice {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Choose Phone"];
    actionSheet.delegate = self;
    [actionSheet bk_addButtonWithTitle:@"Cell Phone" handler:^{
        [self callCellPhone];
    }];
    [actionSheet bk_addButtonWithTitle:@"Office Phone" handler:^{
        [self callOfficePhone];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showFromTabBar:(UITabBar *)[AppDelegate sharedDelegate].tabBarController.tabBar];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [[ThemeManager sharedTheme] buttonTintColor];
        }
    }
}

- (void) callCellPhone {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.user.employeeInfo.cellPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void) callOfficePhone {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.user.employeeInfo.officePhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    controller.mailComposeDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}


@end
