//
//  NSDate+BadgeFormattedDate.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/20/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BadgeFormattedDate)

+ (NSDate *)dateFromFormattedString:(NSString *)formattedString;
- (NSString *)badgeFormattedDate;

@end
