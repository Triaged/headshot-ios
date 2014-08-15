//
//  User.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "User.h"
#import "Company.h"
#import "EmployeeInfo.h"


@implementation User

@dynamic account;
@dynamic identifier;
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic installedApp;
@dynamic sharingOfficeLocation;
@dynamic email;
@dynamic avatarFaceUrl;
@dynamic avatarFace2xUrl;
@dynamic avatarUrl;
@dynamic employeeInfo;
@dynamic company;
@dynamic department;
@dynamic currentOfficeLocation;
@dynamic manager;
@dynamic subordinates;
@dynamic messageThreads;

+ (void)initialize
{
    [self registerCRUDBaseURL:[NSURL URLWithString:@"users"]];
}

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"users.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

+ (NSArray *)findAllExcludeCurrent
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
    return [User MR_findAllWithPredicate:predicate];
}

- (NSString *)nameInitials
{
    return [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
}

@end
