//
//  FileLogger.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DDFileLogger.h>

@interface FileLogManager : NSObject

+ (FileLogManager *)sharedManager;
- (void)setUpFileLogging;
- (void)composeEmailWithDebugAttachment;

@end
