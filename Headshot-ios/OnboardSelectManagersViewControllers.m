//
//  OnboardSelectManagersViewControllers.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/19/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardSelectManagersViewControllers.h"
#import "ContactsDataSource.h"
#import "ContactCell.h"
#import "User.h"

@interface OnboardSelectManagersViewControllers ()

@property (strong, nonatomic) ContactsDataSource *contactsDataSource;

@end

@implementation OnboardSelectManagersViewControllers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (!self) {
        return nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTouched:)];
    self.contactsDataSource = [[ContactsDataSource alloc] init];
    self.tableView.dataSource = self.contactsDataSource;
    self.contactsDataSource.users = [User findAllExcludeCurrent];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)cancelButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelSelectManagersViewController:)]) {
        [self.delegate didCancelSelectManagersViewController:self];
    }
}

#pragma mark - UITableView Data Source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contactsDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.contactsDataSource userAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(selectManagersViewController:didSelectUser:)]) {
        [self.delegate selectManagersViewController:self didSelectUser:user];
    }
}



@end
