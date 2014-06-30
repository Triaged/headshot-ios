//
//  User.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "User.h"
#import "Company.h"
#import "EmployeeInfo.h"


@implementation User

@dynamic identifier;
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic installedApp;
@dynamic email;
@dynamic avatarFaceUrl;
@dynamic avatarUrl;
@dynamic employeeInfo;
@dynamic company;
@dynamic manager;
@dynamic subordinates;

+ (void)initialize
{
    [self registerCRUDBaseURL:[NSURL URLWithString:@"users"]];
}

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"users.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

- (void)emailMessage:(NSString *)messageText withCompletion:(void (^)(NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"users/%@/email_message", self.identifier];
    NSDictionary *parameters = @{@"message" : @{@"body": messageText}};
    [[HeadshotRequestAPIClient sharedClient] POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (NSString *)nameInitials
{
    return [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
}
@end
