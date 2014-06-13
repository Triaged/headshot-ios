//
//  NotificationManager.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageThreadViewController;

@interface NotificationManager : NSObject

@property (strong, nonatomic) MessageThreadViewController *visibleMessageThreadViewController;

+ (NotificationManager *)sharedManager;

@end
