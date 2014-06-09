//
//  SharedImageCache.h
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FICImageCache.h"

@interface SharedImageCache : NSObject <FICImageCacheDelegate>

@property (strong, nonatomic) FICImageCache *cache;


+ (instancetype)sharedClient;
- (void) configureFastImageCache;

@end
