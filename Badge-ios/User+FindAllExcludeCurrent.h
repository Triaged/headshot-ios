//
//  User+FindAllExcludeCurrent.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "User.h"

@interface User (FindAllExcludeCurrent)

+ (NSArray *)findAllExcludeCurrent;

@end
