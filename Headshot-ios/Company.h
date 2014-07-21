//
//  Company.h
//  Headshot-ios
//
//  Created by Charlie White on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, OfficeLocation;

@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString *logoURL;
@property (nonatomic, retain) NSNumber * usesDepartments;
@property (nonatomic, retain) NSSet *officeLocations;
@property (nonatomic, retain) NSSet *departments;
@property (nonatomic, retain) NSSet *users;

+ (void)companyWithCompletionHandler:(void(^)(Company *company, NSError *error))completionHandler;
@end



@interface Company (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;
- (void)addOfficeLocations:(NSSet *)values;
- (void)removeOfficeLocations:(NSSet *)values;
- (void)addDepartmentObject:(Department *)value;
- (void)removeDepartmentObject:(Department *)value;
- (void)addDepartments:(NSSet *)values;
- (void)removeDepartments:(NSSet *)values;

@end
