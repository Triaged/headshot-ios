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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"EE, d LLLL yyyy HH:mm:ss Z";
    return [dateFormat stringFromDate:self];
}

@end
