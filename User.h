//
//  User.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLRESTfulCoreData.h"
#import "HeadshotAPIClient.h"


@class Company, EmployeeInfo, Department, OfficeLocation;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * avatarFaceUrl;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) EmployeeInfo *employeeInfo;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) User *manager;
@property (nonatomic, retain) Department *department;
@property (nonatomic, retain) NSSet *subordinates;
@property (nonatomic, retain) OfficeLocation *currentOfficeLocation;
@property (nonatomic, retain) OfficeLocation *primaryOfficeLocation;

@property (readonly) NSString *nameInitials;

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler;

@end

@interface NSManagedObject (SLRESTfulCoreDataQueryInterface)

- (void)updateWithCompletionHandler:(void(^)(id managedObject, NSError *error))completionHandler;

@end
