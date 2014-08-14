//
//  Company.m
//  Headshot-ios
//
//  Created by Charlie White on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Company.h"
#import "User.h"
#import "SLRESTfulCoreData.h"
#import "HeadshotAPIClient.h"


@implementation Company

@dynamic identifier;
@dynamic name;
@dynamic logoURL;
@dynamic usesDepartments;
@dynamic users;
@dynamic officeLocations;
@dynamic departments;

+ (void)companyWithCompletionHandler:(void(^)(Company *company, NSError *error))completionHandler {
    [[HeadshotAPIClient sharedClient] GET:@"company" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        SLRESTful can not handle the associated ids passed in the user objects unless the users behind the association are already in core data. So we must iterate through the users again after saving the company and update them.
        Company *company = [Company updatedObjectWithRawJSONDictionary:responseObject[0] inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        for (NSDictionary *userData in responseObject[0][@"users"]) {
            [User updatedObjectWithRawJSONDictionary:userData inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        }
        if (completionHandler) {
            completionHandler(company, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
    
}

@end
