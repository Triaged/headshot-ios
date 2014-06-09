//
//  ContactViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactViewController.h"
#import "EmployeeInfo.h"
#import "OfficeLocation.h"
#import "MessageThreadViewController.h"

@interface ContactViewController ()

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
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    
    NSURL *avatarUrl = [NSURL URLWithString:self.user.avatarFaceUrl];
    [avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    self.nameLabel.text = self.user.name;
    self.titleLabel.text = self.user.employeeInfo.jobTitle;
    self.currentOfficeLocationLabel.text = self.user.employeeInfo.currentOfficeLocation.streetAddress;
    
}

-(void) viewWillAppear:(BOOL)animated {
    [[AppDelegate sharedDelegate].tabBarController setTabBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageTapped:(id)sender {
    MessageThreadViewController *threadVC = [[MessageThreadViewController alloc] init];
    [threadVC createOrFindThreadForRecipient:self.user];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:threadVC animated:YES];
}

- (IBAction)emailTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[self.user.email]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (IBAction)meetTapped:(id)sender {
}

- (IBAction)callTapped:(id)sender {
    if (self.user.employeeInfo.cellPhone) {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.user.employeeInfo.cellPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
