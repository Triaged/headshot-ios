//
//  CrashManager.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 8/13/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashManager : NSObject

+ (instancetype)sharedManager;
- (void)start;
- (void)setupForUser;

@end
