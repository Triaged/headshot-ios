//
//  NSDate+BadgeFormattedDate.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/20/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NSDate+BadgeFormattedDate.h"

@implementation NSDate (BadgeFormattedDate)

+ (NSDateFormatter *)badgeDateFormatter
{
    static NSDateFormatter *dateFormmatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormmatter = [[NSDateFormatter alloc] init];
        dateFormmatter.dateFormat = @"EE, d LLLL yyyy HH:mm:ss Z";
    });
    return dateFormmatter;
}

+ (NSDate *)dateFromFormattedString:(NSString *)formattedString
{
    NSDateFormatter *dateFormatter = [NSDate badgeDateFormatter];
    return [dateFormatter dateFromString:formattedString];
    
}

- (NSString *)badgeFormattedDate
{
    NSDateFormatter *dateFormat = [NSDate badgeDateFormatter];
    return [dateFormat stringFromDate:self];
}

@end
