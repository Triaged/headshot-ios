//
//  Account.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) User *currentUser;

+ (void)currentAccountWithCompletionHandler:(void(^)(Account *account, NSError *error))completionHandler;

@end
