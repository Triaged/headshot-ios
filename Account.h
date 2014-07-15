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
+ (void)requestPasswordResetForEmail:(NSString *)email completion:(void(^)(NSString *message, NSError *error))completionHandler;
- (void)updateAccountWithSuccess:(void (^)(Account *account))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)updatePassword:(NSString *)currentPassword password:(NSString *)password confirmedPassword:(NSString *)confirmedPassword withSuccess:(void (^)())success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (void)updateAvatarImage:(UIImage *)image withCompletion:(void (^)(UIImage *image, NSError *error))completion;
- (void)logoutWithCompletion:(void (^)(NSError *error))completion;
- (void)resetBadgeCount;

@end
