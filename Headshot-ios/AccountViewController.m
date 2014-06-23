//
//  AccountViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AccountViewController.h"
#import "EmployeeInfo.h"
#import "OfficeLocation.h"
#import "OnboardNavigationController.h"
#import "CredentialStore.h"
#import "LoginViewController.h"
#import "ContactDetailsDataSource.h"
#import "SettingsViewController.h"

@interface AccountViewController ()

@property (nonatomic, strong) ContactDetailsDataSource *contactDetailsDataSource;

@end

@implementation AccountViewController

@synthesize currentUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    info.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
    [info addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:info];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
                                              
    
    //self.title = @"Account";
    
    currentUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    // Do any additional setup after loading the view from its nib.
    
    NSURL *avatarUrl = [NSURL URLWithString:currentUser.avatarFaceUrl];
    [self.avatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar"]];
    self.nameLabel.text = currentUser.fullName;
    self.titleLabel.text = currentUser.employeeInfo.jobTitle;
    self.currentOfficeLocationLabel.text = currentUser.currentOfficeLocation.streetAddress;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOnboard)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:tap
     ];
    
    self.contactDetailsDataSource = [[ContactDetailsDataSource alloc] initWithUser:currentUser];
    self.contactDetailsDataSource.contactVC = self;
    self.contactDetailsTableView.dataSource = self.contactDetailsDataSource;
    self.contactDetailsTableView.delegate = self.contactDetailsDataSource;
    self.contactDetailsTableView.scrollEnabled = NO;
    self.contactDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.contactDetailsTableView registerNib:[UINib nibWithNibName:@"ContactInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactInfoCell"];
}

-(void) viewWillAppear:(BOOL)animated {
    [self.contactDetailsTableView reloadData];
}

-(void)viewDidLayoutSubviews
{
    CGFloat height = MIN(self.view.bounds.size.height, self.contactDetailsTableView.contentSize.height);
    self.tableHeightConstraint.constant = height;
    [self.view layoutIfNeeded];
}

- (void)showOnboard
{
//    [AppDelegate sharedDelegate].window.rootViewController = [[OnboardNavigationController alloc] init];
    [self.navigationController pushViewController:[SettingsViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
