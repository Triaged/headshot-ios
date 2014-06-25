//
//  OfficeLocation.h
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HeadshotRequestAPIClient.h"

@class Company;

@interface OfficeLocation : NSManagedObject

@property (nonatomic, retain) NSString * streetAddress;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) Company *company;



+ (void)officeLocationsWithCompletionHandler:(void(^)(NSArray *locations, NSError *error))completionHandler;
- (void)postWithSuccess:(void(^)(OfficeLocation *officeLocation))success failure:(void(^)(NSError *error))failure;

- (void)enterLocation;
- (void)exitLocation;



@end
