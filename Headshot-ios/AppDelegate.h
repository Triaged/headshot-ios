//
//  AppDelegate.h
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTabBarController.h"




@class Store;
@class Geofencer;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TRTabBarController *tabBarController;
@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) Geofencer* geofencer;


+ (instancetype)sharedDelegate;

- (void)logout;


@end
