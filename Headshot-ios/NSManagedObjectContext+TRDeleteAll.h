//
//  NSManagedObjectContext+TRDeleteAll.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 8/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (TRDeleteAll)

- (void)deleteAllWithClass:(Class)aClass;

- (void)deleteAllWithEntityName:(NSString *)entityName;

@end
