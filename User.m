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

@dynamic identifier;
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic installedApp;
@dynamic sharingOfficeLocation;
@dynamic email;
@dynamic avatarFaceUrl;
@dynamic avatarUrl;
@dynamic employeeInfo;
@dynamic company;
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

- (NSString *)nameInitials
{
    return [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
}
@end
