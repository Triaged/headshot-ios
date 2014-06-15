//
//  Company.m
//  Headshot-ios
//
//  Created by Charlie White on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Company.h"
#import "User.h"
#import "SLRESTfulCoreData.h"


@implementation Company

@dynamic identifier;
@dynamic name;
@dynamic usesDepartments;
@dynamic users;

+ (void)companyWithCompletionHandler:(void(^)(Company *company, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"company.json"];
    [self fetchObjectFromURL:URL completionHandler:completionHandler];
}

@end
