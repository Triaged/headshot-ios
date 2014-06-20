//
//  EmployeeInfo.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@class OfficeLocation;

@interface EmployeeInfo : NSManagedObject

@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSDate * jobStartDate;
@property (nonatomic, retain) NSDate * birthDate;
@property (nonatomic, retain) NSString * cellPhone;
@property (nonatomic, retain) NSString * officePhone;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) User *user;

@end
