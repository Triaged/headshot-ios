//
//  NSDate+BadgeFormattedDate.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/20/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NSDate+BadgeFormattedDate.h"

@implementation NSDate (BadgeFormattedDate)

- (NSString *)badgeFormattedDate
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EE, d LLLL yyyy HH:mm:ss Z";
    });
    return [dateFormatter stringFromDate:self];
}

@end
