//
//  OnboardSelectOfficeViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectOfficeViewController.h"
#import "OnboardAddOfficeViewController.h"

@interface OnboardSelectOfficeViewController ()

@property (strong, nonatomic) UIButton *nextButton;

@end

@implementation OnboardSelectOfficeViewController

@synthesize delegate;

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
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 249)];
    UIImageView *jobImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding-location"]];
    jobImageView.centerX = headerView.width/2.0;
    jobImageView.y = 30;
    [headerView addSubview:jobImageView];
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.size = CGSizeMake(236, 80);
    descriptionLabel.centerX = headerView.width/2.0;
    descriptionLabel.y = jobImageView.bottom;
    descriptionLabel.numberOfLines = 2;
    descriptionLabel.text = @"At Which Office Do You Work?";
    descriptionLabel.font = [ThemeManager regularFontOfSize:24];
    descriptionLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:descriptionLabel];
    self.tableView.tableHeaderView = headerView;
    
    self.offices = @[];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.offices.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.font = [ThemeManager regularFontOfSize:17];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    cell.detailTextLabel.font = [ThemeManager regularFontOfSize:13];
    cell.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
    cell.textLabel.text = @"Add a New Office";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnboardAddOfficeViewController *addOfficeViewController = [[OnboardAddOfficeViewController alloc] init];
    [self.navigationController pushViewController:addOfficeViewController animated:YES];
}

@end
