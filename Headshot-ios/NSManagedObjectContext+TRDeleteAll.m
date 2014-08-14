//
//  NSManagedObjectContext+TRDeleteAll.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 8/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NSManagedObjectContext+TRDeleteAll.h"

@implementation NSManagedObjectContext (TRDeleteAll)

- (void)deleteAllWithClass:(Class)aClass
{
    [self deleteAllWithEntityName:NSStringFromClass(aClass)];
}

- (void)deleteAllWithEntityName:(NSString *)entityName
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * objects = [self executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject * obj in objects) {
        [self deleteObject:obj];
    }
}

@end
