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
@dynamic email;
@dynamic avatarFaceUrl;
@dynamic avatarUrl;
@dynamic employeeInfo;
@dynamic company;
@dynamic manager;
@dynamic subordinates;

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"users.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}


-(void)fetchOrgStructure {
    NSURL *managerURL = [NSURL URLWithString:[NSString stringWithFormat:@"users/%@/manager", self.identifier]];
    [self fetchObjectsForRelationship:@"manager" fromURL:managerURL completionHandler:^(NSArray *fetchedObjects, NSError *error) {}];
    
    NSURL *subordinatesURL = [NSURL URLWithString:[NSString stringWithFormat:@"users/%@/subordinates", self.identifier]];
    [self fetchObjectsForRelationship:@"subordinates" fromURL:subordinatesURL completionHandler:^(NSArray *fetchedObjects, NSError *error) {}];
}


@end
