//
//  ContactDetailsDataSource.m
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactDetailsDataSource.h"
#import "ContactSectionViewController.h"
#import "ContactInfoTableViewCell.h"
#import "ContactCell.h"

typedef NS_ENUM(NSUInteger, ContactDetailType)  {
    kAvailability,
    kReportsTo,
    kReports,
    kContactInfo
};

@implementation ContactDetailsDataSource

@synthesize contactDetailsArray, currentUser;

- (id)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        // Custom initialization
        currentUser = user;
        
        contactDetailsArray = [[NSMutableArray alloc] init];
        
        [self setupAvailability];
        [self setupReports];
        [self setupContactInfo];
    }
    return self;
}

#pragma mark 

-(void)setupContactInfo {
    NSMutableArray *contactInfo = [[NSMutableArray alloc] init];
    
    if (currentUser.email)
        [contactInfo addObject:@[@"Email", currentUser.email]];

    if (currentUser.employeeInfo.cellPhone)
        [contactInfo addObject:@[@"Mobile", currentUser.employeeInfo.cellPhone]];

    if (currentUser.employeeInfo.officePhone)
        [contactInfo addObject:@[@"Office", currentUser.employeeInfo.officePhone]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"d LLLL yyyy";
    if (currentUser.employeeInfo.birthDate) {
        [contactInfo addObject:@[@"Birthday", [dateFormatter stringFromDate:currentUser.employeeInfo.birthDate]]];
    }

    if (currentUser.employeeInfo.jobStartDate) {
        [contactInfo addObject:@[@"Start Date", [dateFormatter stringFromDate:currentUser.employeeInfo.jobStartDate]]];
    }

    [contactDetailsArray addObject:@{[NSNumber numberWithInt:kContactInfo] : contactInfo}];

}

-(void)setupAvailability {
    if (currentUser.currentOfficeLocation) {
        [contactDetailsArray addObject:@{[NSNumber numberWithInt:kAvailability] : @[currentUser.currentOfficeLocation.name]}];
    } else {
        [contactDetailsArray addObject:@{[NSNumber numberWithInt:kAvailability] : @[@"Out Of Office"]}];
    }
    
}

-(void)setupReports {
    
    if (currentUser.manager)
        [contactDetailsArray addObject:@{[NSNumber numberWithInt:kReportsTo] : @[currentUser.manager]}];
    
    if (currentUser.subordinates.count > 0)
        [contactDetailsArray addObject:@{[NSNumber numberWithInt:kReports] : [currentUser.subordinates allObjects]}];
}



- (NSArray *)rowsForSectionWithSection:(NSInteger)section {
    NSDictionary *sectionDict = [contactDetailsArray objectAtIndex:section];
    NSArray *sectionArray = [sectionDict objectForKey:[[sectionDict allKeys] firstObject]];;
    return sectionArray;
}

- (NSString *)titleForSection:(NSInteger)section {
    NSInteger contactDetailType = [self contactDetailTypeForIndexPath:section];
    NSString *sectionTitle;
    
     switch (contactDetailType) {
        case kAvailability:
            sectionTitle = @"AVAILABILITY";
            break;
        case kReportsTo:
            sectionTitle =  @"REPORTS TO";
            break;
        case kReports:
            sectionTitle = @"DIRECT REPORTS";
            break;
        case kContactInfo:
            sectionTitle = @"CONTACT INFO";
            break;
    }
    
    return sectionTitle;
}

- (NSInteger)rowCountForSectionWithSection:(NSInteger)section {
    NSInteger count = [[self rowsForSectionWithSection:section] count];

    return count;
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDict = [contactDetailsArray objectAtIndex:indexPath.section];
    NSArray *sectionArray = [sectionDict objectForKey:[[sectionDict allKeys] firstObject]];
    return [sectionArray objectAtIndex:indexPath.row];
}

- (NSInteger)contactDetailTypeForIndexPath:(NSInteger)section {
    NSDictionary *sectionDict = [contactDetailsArray objectAtIndex:section];
     return [(NSNumber *)[[sectionDict allKeys] firstObject] integerValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [contactDetailsArray count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [self rowCountForSectionWithSection:section];
}



- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger contactDetailType = [self contactDetailTypeForIndexPath:indexPath.section];
    UITableViewCell *cell;
    
    switch (contactDetailType) {
        case kReports:
            cell = [self tableView:tableView reportsCellForRowAtIndexPath:indexPath];
            break;
        case kReportsTo:
            cell = [self tableView:tableView reportsCellForRowAtIndexPath:indexPath];
            break;
       case kContactInfo:
            cell = [self tableView:tableView contactInfoCellForRowAtIndexPath:indexPath];
            break;
        default:
            cell = [self tableView:tableView defaultCellForRowAtIndexPath:indexPath];
            break;
    }
    
    
    return cell;
    }

- (UITableViewCell*)tableView:(UITableView*)tableView reportsCellForRowAtIndexPath:(NSIndexPath*)indexPath {
    User *user = [self itemAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.user = user;
    
    NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];//first get total rows in that section by current indexPath.
    if(indexPath.row != totalRow -1){
        [cell displayCustomSeparator];
    }
    
    return cell;
}


- (UITableViewCell*)tableView:(UITableView*)tableView contactInfoCellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSArray *row = [self itemAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"ContactInfoCell";
    ContactInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
    if (!cell) {
        cell = [[ContactInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell configureForLabel:[row firstObject] andValue:[row lastObject]];
    
    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView defaultCellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString *row = [self itemAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"messageThreadCell";
    UITableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier:CellIdentifier ] ;
    if ( !cell )
    {
        cell = [ [ UITableViewCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier ] ;
    }
    
    cell.textLabel.text = row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger contactDetailType = [self contactDetailTypeForIndexPath:indexPath.section];
    
    switch (contactDetailType) {
        case kReports:
            [self tableView:tableView didSelectReportAtIndexPath:indexPath];
            break;
        case kReportsTo:
            [self tableView:tableView didSelectReportAtIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectReportAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self itemAtIndexPath:indexPath];
    
    ContactViewController *contactVC = [[ContactViewController alloc] initWitUser:user];
    self.contactVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.contactVC.navigationController pushViewController:contactVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ContactSectionViewController *contactVC = [[ContactSectionViewController alloc] initWithText:[self titleForSection:section]];
    return contactVC.view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contactDetailType = [self contactDetailTypeForIndexPath:indexPath.section];
    
    switch (contactDetailType) {
        case kReports:
            return 55;
            break;
        case kReportsTo:
            return 55;
            break;
        case kContactInfo:
            return 55;
            break;
        default:
            return 44;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

@end
