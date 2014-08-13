//
//  TRDataStoreManager.m
//  Triage-ios
//
//  Created by Charlie White on 2/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "TRDataStoreManager.h"
#import <MagicalRecord.h>
#import "NSManagedObjectContext+TRDeleteAll.h"
#import "Message.h"
#import "MessageThread.h"
#import "User.h"
#import "Account.h"
#import "Company.h"
#import "EmployeeInfo.h"
#import "OfficeLocation.h"
#import "Department.h"

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
    
    
    NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:kPersistentStoreName];
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

- (void)resetPersistentStore:(void (^)())completion
{
    [self.mainThreadManagedObjectContext reset];
    NSArray *entityNames = @[NSStringFromClass([User class]),
                             NSStringFromClass([Message class]),
                             NSStringFromClass([MessageThread class]),
                             NSStringFromClass([Account class]),
                             NSStringFromClass([Company class]),
                             NSStringFromClass([EmployeeInfo class]),
                             NSStringFromClass([OfficeLocation class]),
                             NSStringFromClass([Department class])];
    for (NSString *name in entityNames) {
        [self.mainThreadManagedObjectContext deleteAllWithEntityName:name];
    }
    NSError *saveError = nil;
    [self.mainThreadManagedObjectContext save:&saveError];
    self.mainThreadManagedObjectContext = nil;
    [self.backgroundThreadManagedObjectContext performBlock:^{
        [self.backgroundThreadManagedObjectContext reset];
        [self.backgroundThreadManagedObjectContext processPendingChanges];
        self.backgroundThreadManagedObjectContext = nil;
        jadispatch_main_qeue(^{
            [[AppDelegate sharedDelegate] setDataStore];
            if (completion) {
                completion();
            }
        });
    }];
}


@end
