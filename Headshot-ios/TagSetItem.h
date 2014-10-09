//
//  TagSetItem.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/8/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TagSet, User;

@interface TagSetItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) TagSet *tagSet;
@end

@interface TagSetItem (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
