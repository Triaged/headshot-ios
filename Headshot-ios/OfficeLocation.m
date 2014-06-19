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
@dynamic latitude;
@dynamic longitude;

+ (void)officeLocationsWithCompletionHandler:(void(^)(NSArray *locations, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"office_locations.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

- (void)postWithSuccess:(void(^)(OfficeLocation *officeLocation))success failure:(void(^)(NSError *error))failure
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
    [[HeadshotRequestAPIClient sharedClient] POST:@"office_locations/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error) {
            failure(error);
        }
    }];
}

- (void)enterLocation {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"office_locations/%@/entered", self.identifier]];
    [self postToURL:URL completionHandler:nil];
    NSLog(@"entered location");
}


- (void)exitLocation {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"office_locations/%@/exited", self.identifier]];
    [self deleteToURL:URL completionHandler:nil];
        NSLog(@"exited location");
}

    
@end
