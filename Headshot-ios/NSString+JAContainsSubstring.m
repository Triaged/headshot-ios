//
//  NSString+JAContainsSubstring.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/2/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "NSString+JAContainsSubstring.h"

@implementation NSString (JAContainsSubstring)

- (BOOL)ja_containsSubstring:(NSString *)substring
{
    return [self rangeOfString:substring].location != NSNotFound;
}

@end
