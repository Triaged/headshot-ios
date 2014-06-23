//
//  ContactDetailsDataSource.h
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactViewController.h"
#import "User.h"
#import "EmployeeInfo.h"
#import "OfficeLocation.h"

@interface ContactDetailsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIViewController *contactVC;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableArray *contactDetailsArray;

- (id)initWithUser:(User *)user;

@end
