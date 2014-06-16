//
//  User+FindAllExcludeCurrent.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "User+FindAllExcludeCurrent.h"

@implementation User (FindAllExcludeCurrent)

+ (NSArray *)findAllExcludeCurrent
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
   return [User MR_findAllWithPredicate:predicate];
}

@end
