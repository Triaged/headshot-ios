//
//  TagSet.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/8/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TagSet : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSSet *tagSetItems;
@end

@interface TagSet (CoreDataGeneratedAccessors)

- (void)addTagSetItemsObject:(NSManagedObject *)value;
- (void)removeTagSetItemsObject:(NSManagedObject *)value;
- (void)addTagSetItems:(NSSet *)values;
- (void)removeTagSetItems:(NSSet *)values;

@end
