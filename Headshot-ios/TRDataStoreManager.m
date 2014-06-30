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
    
    if([[NSFileManager defaultManager] removeItemAtURL:[self databaseRootURL] error:&error]){
        [[AppDelegate sharedDelegate] setDataStore];
    }
    else{
        NSLog(@"An error has occurred while deleting %@", [self databaseRootURL]);
        NSLog(@"Error description: %@", error.description);
    }
}

@end
