//
//  Account.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Account.h"
#import "User.h"
#import "SLRESTfulCoreData.h"


@implementation Account

@dynamic identifier;
@dynamic currentUser;


+ (void)currentAccountWithCompletionHandler:(void(^)(Account *account, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"account.json"];
    [self fetchObjectFromURL:URL completionHandler:completionHandler];
}


@end
