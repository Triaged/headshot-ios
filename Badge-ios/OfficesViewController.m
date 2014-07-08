//
//  OfficesViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/24/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OfficesViewController.h"
#import "AddOfficeViewController.h"

@interface OfficesViewController () <AddOfficeViewControllerDelegate>

@end

@implementation OfficesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTouched:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.offices = [OfficeLocation MR_findAll];
}

- (void)cancelButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelOfficesViewController:)]) {
         [self.delegate didCancelOfficesViewController:self];
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
    }
    else if (indexPath.row == self.offices.count) {
        cell.textLabel.text = @"I don't work in an office";
        cell.detailTextLabel.text = nil;
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
        [self didSelectOffice:office];
    }
    else if (indexPath.row == self.offices.count) {
        [self didSelectOffice:nil];
    }
    else {
        [self addOffice];
    }
}

- (void)addOffice
{
    AddOfficeViewController *addOfficeViewController = [[AddOfficeViewController alloc] init];
    addOfficeViewController.delegate = self;
    [self presentViewControllerWithNav:addOfficeViewController animated:YES completion:nil];
    
}

- (void)didSelectOffice:(OfficeLocation *)office
{
    if ([self.delegate respondsToSelector:@selector(officesViewController:didSelectOffice:)]) {
        [self.delegate officesViewController:self didSelectOffice:office];
    }
}

#pragma mark - Add Office View Controller Delegate
- (void)didCancelOfficeViewController:(AddOfficeViewController *)addOfficeViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
