//
//  Department.h
//  Headshot-ios
//
//  Created by Charlie White on 6/12/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *users;

+ (void)departmentsWithCompletionHandler:(void(^)(NSArray *departments, NSError *error))completionHandler;
@end


@interface Department (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
