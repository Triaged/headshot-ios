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
#import "TRDataStoreManager.h"


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
        NSManagedObjectContext *backgroundContext = [TRDataStoreManager sharedInstance].backgroundThreadManagedObjectContext;
        [backgroundContext performBlock:^{
            Company *company = [Company updatedObjectWithRawJSONDictionary:responseObject inManagedObjectContext:backgroundContext];
            for (NSDictionary *userData in responseObject[@"users"]) {
                [User updatedObjectWithRawJSONDictionary:userData inManagedObjectContext:backgroundContext];
            }
            NSManagedObjectID *companyID = company.objectID;
            if (completionHandler) {
                [[TRDataStoreManager sharedInstance].mainThreadManagedObjectContext performBlockAndWait:^{
                    Company *mainCompany = (Company *)[[TRDataStoreManager sharedInstance].mainThreadManagedObjectContext existingObjectWithID:companyID error:nil];
                    completionHandler(mainCompany, nil);
                }];
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
    
}

@end
