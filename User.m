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
#import "TagSetItem.h"


@implementation User

@dynamic account;
@dynamic identifier;
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic installedApp;
@dynamic sharingOfficeLocation;
@dynamic archived;
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
@dynamic tagSetItems;

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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@ && archived == NO", [AppDelegate sharedDelegate].store.currentAccount.identifier];
    return [User MR_findAllWithPredicate:predicate];
}

+ (NSArray *)findAllIntersectingfItems:(NSArray *)tagSetItems excludeCurrent:(BOOL)excludeCurrent
{
    NSArray *users = excludeCurrent ? [User findAllExcludeCurrent] : [User MR_findAll];
    NSMutableSet *userSet = [[NSMutableSet alloc] initWithArray:users];
    for (TagSetItem *tagSetItem in tagSetItems) {
        [userSet intersectSet:tagSetItem.users];
    }
    return userSet.allObjects;
}

- (NSString *)nameInitials
{
    return [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
}

@end
