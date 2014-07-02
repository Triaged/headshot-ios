//
//  VersionManager.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "VersionManager.h"
#import "HeadshotRequestAPIClient.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@implementation VersionManager

+ (instancetype)sharedManager
{
    static VersionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[VersionManager alloc] init];
    });
    return _sharedManager;
}

- (NSNumber *)bundleVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)checkForUpdateWithCompletion:(void (^)(NSNumber *version, NSError *error))completion
{
    [[HeadshotRequestAPIClient sharedClient] GET:@"versions/ios" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *version = responseObject[@"version"];
        if (completion) {
            completion(version, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)notifyOfUpdate
{
    [self checkForUpdateWithCompletion:^(NSNumber *version, NSError *error) {
        if (version && version.integerValue > [self bundleVersion].integerValue) {
            NSString *message = @"The version of Badge you are using is no longer supported. Please download the latest version.";
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Please Update" message:message];
            [alertView bk_setCancelButtonWithTitle:@"Update Badge" handler:^{
                NSURL *url = [NSURL URLWithString:@"http://badge.co/beta_distribution"];
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alertView show];
        }
    }];
}

@end
