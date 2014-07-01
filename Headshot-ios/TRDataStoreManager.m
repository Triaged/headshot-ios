//
//  TRDataStoreManager.m
//  Triage-ios
//
//  Created by Charlie White on 2/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRDataStoreManager.h"

@implementation TRDataStoreManager

- (NSString *)managedObjectModelName
{
    return @"Headshot";
}

-(NSURL *)databaseRootURL
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *rootURL = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:applicationName];
    NSURL *dbRoot = [NSURL fileURLWithPath:rootURL];
    return dbRoot;
}

- (void)cleanAndResetupDB
{
    NSError *error = nil;
    
    [MagicalRecord cleanUp];
    
    
    NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:@"Headshot.sqlite"];
    if([[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]){
        // reset setup.
        
        NSLog(@"%hhd", [[NSFileManager defaultManager] fileExistsAtPath:[fileURL absoluteString]]);
        [[AppDelegate sharedDelegate] setDataStore];
    }
    else{
        NSLog(@"An error has occurred while deleting %@", [self databaseRootURL]);
        NSLog(@"Error description: %@", error.description);
    }
}

- (void)resetPersistentStore
{
    NSLog(@"resetting persistent store");
    NSError *error = nil;
    
    [MagicalRecord cleanUp];
    
    // FIXME: dirty. If there are many stores...
    //NSPersistentStore *store = [[self.managedObjectContext.persistentStoreCoordinator persistentStores] lastObject];
    
    //    if (![self.managedObjectContext.persistentStoreCoordinator removePersistentStore:store error:&error]) {
    //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //        abort();
    //    }
    
    // Delete file
    NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:@"Headshot.sqlite"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [TRDataStoreManager sharedInstance].mainThreadManagedObjectContext = nil;
    [TRDataStoreManager sharedInstance].backgroundThreadManagedObjectContext = nil;
    
    //[NSManagedObjectContext MR_setDefaultContext: nil];
    [NSPersistentStore MR_setDefaultPersistentStore:nil];
    [NSManagedObjectModel MR_setDefaultManagedObjectModel:nil];
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator: nil];
    
    
    
    [[AppDelegate sharedDelegate] setDataStore];
}


@end
