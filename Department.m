//
//  Department.m
//  Headshot-ios
//
//  Created by Charlie White on 6/12/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Department.h"
#import "User.h"


@implementation Department

@dynamic identifier;
@dynamic name;
@dynamic users;

+ (void)initialize
{
    [self registerCRUDBaseURL:[NSURL URLWithString:@"departments/"]];
}

+ (void)departmentsWithCompletionHandler:(void(^)(NSArray *departments, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"departments.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

@end
