//
//  Store.h
//  Docked-ios
//
//  Created by Charlie White on 10/3/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "Company.h"

@class NSFetchedResultsController;

@interface Store : NSObject

+ (instancetype)store;

- (Account *) currentAccount;
- (Company *)currentCompany;
- (void) fetchRemoteUserAccount;
- (void) setCurrentAccount: (Account *)account;
- (void) fetchRemoteUserAccount;


@end
