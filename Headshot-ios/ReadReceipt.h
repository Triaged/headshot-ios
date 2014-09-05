//
//  ReadReceipt.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/3/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, User;

@interface ReadReceipt : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * acknowledged;
@property (nonatomic, retain) Message *message;
@property (nonatomic, retain) User *user;

+ (void)postReceipts:(NSArray *)receipts withCompletion:(void (^)(NSArray *receipts, NSError *error))completion;

@end
