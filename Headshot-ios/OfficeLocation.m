//
//  OfficeLocation.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OfficeLocation.h"
#import "SLRESTfulCoreData.h"


@implementation OfficeLocation

@dynamic streetAddress;
@dynamic city;
@dynamic state;
@dynamic zipCode;
@dynamic country;
@dynamic identifier;
@dynamic name;
@dynamic latitude;
@dynamic longitude;
@dynamic company;

+ (void)officeLocationsWithCompletionHandler:(void(^)(NSArray *locations, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"office_locations"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

+ (void)initialize
{
    [self registerCRUDBaseURL:[NSURL URLWithString:@"office_locations/"]];
    [self registerJSONPrefix:@"office_location"];
}

- (void)postWithCompletion:(void(^)(OfficeLocation *officeLocation, NSError *error))completion
{
    NSMutableDictionary *officeJSON = [[NSMutableDictionary alloc] init];
    [officeJSON setObject:self.streetAddress forKey:@"street_address"];
    [officeJSON setObject:self.city forKey:@"city"];
    [officeJSON setObject:self.state forKey:@"state"];
    if (self.country) {
        [officeJSON setObject:self.country forKey:@"country"];
    }
    if (self.zipCode) {
        [officeJSON setObject:self.zipCode forKey:@"zip_code"];
    }
    
    NSDictionary *parameters = @{@"office_location" : officeJSON};
    [[HeadshotAPIClient sharedClient] POST:@"office_locations/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self updateWithRawJSONDictionary:responseObject];
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completion) {
            completion(self, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)enterLocation {
    DDLogInfo(@"Starting ENTER location request for region with identifier %@", self.identifier);
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"office_locations/%@/entered", self.identifier]];
    [self postToURL:URL completionHandler:^(id JSONObject, NSError *error) {
        DDLogInfo(@"Finished ENTER location request for region with identifier %@", self.identifier);
        [AppDelegate sharedDelegate].store.currentAccount.currentUser.currentOfficeLocation = self;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }];
    NSLog(@"entered location");
}


- (void)exitLocation {
    DDLogInfo(@"Starting EXIT location request for region with identifier %@", self.identifier);
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"office_locations/%@/exited", self.identifier]];
    [self deleteToURL:URL completionHandler:^(NSError *error) {
        DDLogInfo(@"Finished EXIT location request for region with identifier %@", self.identifier);
        [AppDelegate sharedDelegate].store.currentAccount.currentUser.currentOfficeLocation = nil;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }];
}

    
@end
