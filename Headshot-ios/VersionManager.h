//
//  VersionManager.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionManager : NSObject

+ (instancetype)sharedManager;

- (void)notifyOfUpdate;

@end
