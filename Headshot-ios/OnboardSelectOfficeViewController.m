//
//  OnboardSelectOfficeViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectOfficeViewController.h"
#import "OnboardAddOfficeViewController.h"
#import "OfficeLocation.h"

@interface OnboardSelectOfficeViewController ()

@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) OfficeLocation *selectedOffice;
@property (assign, nonatomic) BOOL noOffice;

@end

@implementation OnboardSelectOfficeViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    
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
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.size = CGSizeMake(self.view.width, 60);
    self.nextButton.bottom = self.view.height;
    self.nextButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.nextButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.nextButton setTitle:@"Continue" forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.nextButton addTarget:self action:@selector(nextButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.nextButton.height, 0);
    
    self.offices = [OfficeLocation MR_findAll];
    
}

- (void)nextButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [ThemeManager regularFontOfSize:17];
    cell.textLabel.textColor = [[ThemeManager sharedTheme] darkGrayTextColor];
    cell.detailTextLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    cell.detailTextLabel.font = [ThemeManager regularFontOfSize:13];
    cell.tintColor = [[ThemeManager sharedTheme] greenColor];
    if (indexPath.row < self.offices.count) {
        OfficeLocation *office = self.offices[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ Office", office.city];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@", office.streetAddress, office.city, office.zipCode];
        if ([self.selectedOffice isEqual:office]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == self.offices.count) {
        cell.textLabel.text = @"I don't work in an office";
        cell.detailTextLabel.text = nil;
        if (self.noOffice) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else {
        cell.textLabel.textColor = [[ThemeManager sharedTheme] orangeColor];
        cell.textLabel.text = @"Add a New Office";
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.offices.count) {
        OfficeLocation *office = self.offices[indexPath.row];
        self.selectedOffice = office;
        self.noOffice = NO;
    }
    else if (indexPath.row == self.offices.count) {
        self.noOffice = YES;
        self.selectedOffice = nil;
    }
    else {
        OnboardAddOfficeViewController *addOfficeViewController = [[OnboardAddOfficeViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addOfficeViewController];
        navigationController.navigationBar.translucent = NO;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    [tableView reloadData];
}

@end