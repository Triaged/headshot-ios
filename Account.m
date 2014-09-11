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

+ (void)requestPasswordResetForEmail:(NSString *)email completion:(void (^)(NSString *, NSError *))completionHandler
{
    NSDictionary *parameters = @{@"email" : email};
    [[HeadshotAPIClient sharedClient] POST:@"account/reset_password" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject[@"message"], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

- (void)updateAccountWithSuccess:(void (^)(Account *account))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *userJSON = [[NSMutableDictionary alloc] init];
    userJSON[@"first_name"] = self.currentUser.firstName;
    userJSON[@"last_name"] = self.currentUser.lastName;
    userJSON[@"email"] = self.currentUser.email;
    Department *department = self.currentUser.department;
    userJSON[@"department_id"] = department ? department.identifier : [NSNull null];
    
    OfficeLocation *primaryOfficeLocation = self.currentUser.primaryOfficeLocation;
    userJSON[@"primary_office_location_id"] = primaryOfficeLocation ? primaryOfficeLocation.identifier : [NSNull null];
    
    User *manager = self.currentUser.manager;
    userJSON[@"manager_id"] = manager ? manager.identifier : [NSNull null];

    NSMutableDictionary *employeeInfoJSON = [[NSMutableDictionary alloc] init];
    employeeInfoJSON[@"job_title"] = self.currentUser.employeeInfo.jobTitle;
    employeeInfoJSON[@"cell_phone"] = self.currentUser.employeeInfo.cellPhone;
    if (self.currentUser.employeeInfo.officePhone) {
        employeeInfoJSON[@"office_phone"] = self.currentUser.employeeInfo.officePhone;
    }
    if (self.currentUser.employeeInfo.birthDate) {
        employeeInfoJSON[@"birth_date"] = self.currentUser.employeeInfo.birthDate.badgeFormattedDate;
    }
    if (self.currentUser.sharingOfficeLocation) {
        userJSON[@"sharing_office_location"] = self.currentUser.sharingOfficeLocation;
    }
    if (self.currentUser.employeeInfo.jobStartDate) {
        employeeInfoJSON[@"job_start_date"] = self.currentUser.employeeInfo.jobStartDate.badgeFormattedDate;
    }
    if (self.currentUser.employeeInfo.website) {
        employeeInfoJSON[@"website"] = self.currentUser.employeeInfo.website;
    }
    if (self.currentUser.employeeInfo.linkedin) {
        employeeInfoJSON[@"linkedin"] = self.currentUser.employeeInfo.linkedin;
    }
    userJSON[@"employee_info_attributes"] = employeeInfoJSON;
    NSDictionary *parameters = @{@"user" : userJSON};
    [[HeadshotAPIClient sharedClient] PUT:@"account/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        Account *account = [Account updatedObjectWithRawJSONDictionary:responseObject inManagedObjectContext:self.managedObjectContext];
        if (success) {
            success(account);
        }
    } failure:failure];
}

- (void)logoutWithCompletion:(void (^)(NSError *error))completion
{
    NSString *deviceIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDeviceIdentifier];
    NSString *path = [NSString stringWithFormat:@"devices/%@/sign_out", deviceIdentifier];
    
    [[HeadshotAPIClient sharedClient] DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)updateAvatarImage:(UIImage *)image withCompletion:(void (^)(UIImage *image, NSError *error))completion
{
    [[HeadshotAPIClient sharedClient] performMultipartFormRequestWithMethod:@"POST" path:@"account/avatar" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        [formData appendPartWithFileData:imageData name:@"user[avatar]" fileName:@"avatar.jpg" mimeType:@"image/jpg"];
        [[AnalyticsManager sharedManager] avatarUploaded];
    } completion:^(id responseObject, NSError *error) {
        [Account updatedObjectWithRawJSONDictionary:responseObject inManagedObjectContext:self.managedObjectContext];
        if (completion) {
            completion(image, error);
        }
    }];
}

- (void)updatePassword:(NSString *)currentPassword password:(NSString *)password confirmedPassword:(NSString *)confirmedPassword withCompletion:(void (^)(NSError *error))completion
{
    NSDictionary *parameters = @{@"user": @{@"current_password": currentPassword,
                                            @"password" :password,
                                            @"password_confirmation" : confirmedPassword}};
    [[HeadshotAPIClient sharedClient] PUT:@"account/update_password" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)resetBadgeCount {
    NSURL *URL = [NSURL URLWithString:@"account/reset_count.json"];
    [self postToURL:URL completionHandler:nil];
}

@end
