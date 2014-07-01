//
//  TRDataStoreManager.h
//  Triage-ios
//
//  Created by Charlie White on 2/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLCoreDataStack.h"

@interface TRDataStoreManager : SLCoreDataStack

- (void)cleanAndResetupDB;
- (void)resetPersistentStore;

@end
