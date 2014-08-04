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
#import "EditAccountViewController.h"
#import "CredentialStore.h"
#import "ContactDetailsDataSource.h"
#import "SettingsViewController.h"
#import "FileLogManager.h"
#import "Constants.h"

@interface AccountViewController ()

@property (nonatomic, strong) ContactDetailsDataSource *contactDetailsDataSource;
@property (strong, nonatomic) UIView *completeProfileView;
@property (assign, nonatomic) BOOL hasShownCompleteProfileView;
@property (strong, nonatomic) UIImage *previousNavBarBackgroundImage;

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
    
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    info.tintColor = [[ThemeManager sharedTheme] buttonTintColor];
    [info addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTouched:)];
    [info addGestureRecognizer:longPress];
    [self.avatarImageView addGestureRecognizer:longPress];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:info];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    
    
    [self loadViewFromData];
    
    self.completeProfileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 48)];
    self.completeProfileView.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    UITapGestureRecognizer *completeProfileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(completeProfileTapped:)];
    [self.completeProfileView addGestureRecognizer:completeProfileTap];
    UILabel *completeProfileLabel = [[UILabel alloc] initWithFrame:self.completeProfileView.bounds];
    completeProfileLabel.text = @"Complete your profile";
    completeProfileLabel.textAlignment = NSTextAlignmentCenter;
    completeProfileLabel.font = [ThemeManager regularFontOfSize:16];
    completeProfileLabel.textColor = [UIColor whiteColor];
    [self.completeProfileView addSubview:completeProfileLabel];
    UIButton *cancelCompleteProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelCompleteProfileButton.size = CGSizeMake(25, 25);
    cancelCompleteProfileButton.x = 15;
    cancelCompleteProfileButton.centerY = self.completeProfileView.height/2.0;
    [cancelCompleteProfileButton setImage:[UIImage imageNamed:@"cancel_white"] forState:UIControlStateNormal];
    [cancelCompleteProfileButton addTarget:self action:@selector(dismissCompleteProfileView) forControlEvents:UIControlEventTouchUpInside];
    [self.completeProfileView addSubview:cancelCompleteProfileButton];
}

-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.previousNavBarBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    //refresh locally
    [self loadViewFromData];
    // refresh remotely
    [self refreshUser];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:self.previousNavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if ([self shouldPromptToCompleteProfile]) {
//        [self showCompleteProfileView];
//    }
}

- (BOOL)shouldPromptToCompleteProfile
{
    BOOL shouldPromptToCompleteProfile = !self.hasShownCompleteProfileView;
    if (shouldPromptToCompleteProfile) {
        User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
        BOOL profileIncomplete = !user.employeeInfo.jobTitle || !user.manager || !user.department || !user.employeeInfo.birthDate || !user.employeeInfo.officePhone || !user.primaryOfficeLocation;
        shouldPromptToCompleteProfile = shouldPromptToCompleteProfile && profileIncomplete;
    }
    return shouldPromptToCompleteProfile;
}

- (void)showCompleteProfileView
{
    self.hasShownCompleteProfileView = YES;
    self.completeProfileView.transform = CGAffineTransformMakeTranslation(0, -self.completeProfileView.height);
    [self.view addSubview:self.completeProfileView];
    [UIView animateWithDuration:0.3 animations:^{
        self.completeProfileView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissCompleteProfileView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.completeProfileView.transform = CGAffineTransformMakeTranslation(0, -self.completeProfileView.height);
    } completion:^(BOOL finished) {
        [self.completeProfileView removeFromSuperview];
    }];
}

-(void)loadViewFromData {
    currentUser = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    self.avatarImageView.user = currentUser;
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
    
    [self.contactDetailsTableView reloadData];
}

- (void) refreshUser {
    [currentUser updateWithCompletionHandler:^(User *user, NSError *error) {
        currentUser = user;
        [self loadViewFromData];
    }];
}

-(void)viewDidLayoutSubviews
{
    self.tableHeightConstraint.constant = self.contactDetailsTableView.contentSize.height;
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

- (void)completeProfileTapped:(id)sender
{
    [self dismissCompleteProfileView];
    [self showEditAccount];
}

- (void)avatarTouched:(id)sender
{
    [[FileLogManager sharedManager] composeEmailWithDebugAttachment];
}

- (void)showEditAccount
{
    EditAccountViewController *editAccountViewController = [[EditAccountViewController alloc] init];
    [self.navigationController pushViewController:editAccountViewController animated:YES];
}

-(void)showSettings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

@end
