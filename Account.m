//
//  Account.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "Account.h"
#import "NSDate+BadgeFormattedDate.h"
#import "User.h"
#import "EmployeeInfo.h"
#import "SLRESTfulCoreData.h"


@implementation Account

@dynamic identifier;
@dynamic currentUser;


+ (void)initialize
{
        [self registerAttributeName:@"currentUser" forJSONObjectKeyPath:@"current_user"];
}

+ (void)currentAccountWithCompletionHandler:(void(^)(Account *account, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"account.json"];
    [self fetchObjectFromURL:URL completionHandler:completionHandler];
}

- (void)updateAccountWithSuccess:(void (^)(Account *account))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *userJSON = [[NSMutableDictionary alloc] init];
    userJSON[@"first_name"] = self.currentUser.firstName;
    userJSON[@"last_name"] = self.currentUser.lastName;
    userJSON[@"department_id"] = @(2);
    userJSON[@"primary_office_location_id"] = @(10);
    NSMutableDictionary *employeeInfoJSON = [[NSMutableDictionary alloc] init];
    employeeInfoJSON[@"job_title"] = self.currentUser.employeeInfo.jobTitle;
    employeeInfoJSON[@"cell_phone"] = self.currentUser.employeeInfo.cellPhone;
    if (self.currentUser.employeeInfo.birthDate) {
        employeeInfoJSON[@"birth_date"] = self.currentUser.employeeInfo.birthDate.badgeFormattedDate;
    }
    employeeInfoJSON[@"job_start_date"] = [NSDate date].badgeFormattedDate;
    userJSON[@"employee_info_attributes"] = employeeInfoJSON;
    NSDictionary *parameters = @{@"user" : userJSON};
    [[HeadshotAPIClient sharedClient] PUT:@"account/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        Account *account = [Account updatedObjectWithRawJSONDictionary:responseObject inManagedObjectContext:self.managedObjectContext];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

@end
