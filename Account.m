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
#import "Department.h"
#import "OfficeLocation.h"
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

- (void)updateAccountWithSuccess:(void (^)(Account *account))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *userJSON = [[NSMutableDictionary alloc] init];
    userJSON[@"first_name"] = self.currentUser.firstName;
    userJSON[@"last_name"] = self.currentUser.lastName;
    if (self.currentUser.department) {
        userJSON[@"department_id"] = self.currentUser.department.identifier;
    }
    if (self.currentUser.primaryOfficeLocation) {
         userJSON[@"primary_office_location_id"] = self.currentUser.primaryOfficeLocation;
    }
    if (self.currentUser.manager) {
        userJSON[@"manager_id"] = self.currentUser.manager.identifier;
    }
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
        if (success) {
            success(account);
        }
    } failure:failure];
}

- (void)updatePassword:(NSString *)currentPassword password:(NSString *)password confirmedPassword:(NSString *)confirmedPassword withSuccess:(void (^)())success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSDictionary *parameters = @{@"user": @{@"current_password": currentPassword,
                                            @"password" :password,
                                            @"password_confirmation" : confirmedPassword}};
    [[HeadshotAPIClient sharedClient] PUT:@"account/update_password" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:failure];
}

@end
