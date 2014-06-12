//
//  User.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FICEntity.h"
#import "SLRESTfulCoreData.h"


@class Company, EmployeeInfo;

@interface User : NSManagedObject <FICEntity>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * avatarFaceUrl;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) EmployeeInfo *employeeInfo;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) User *manager;
@property (nonatomic, retain) NSSet *subordinates;

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler;
-(void)fetchOrgStructure;

@end
