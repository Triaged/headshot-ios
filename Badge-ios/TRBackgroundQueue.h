//
//  TRBackgroundQueue.h
//  Triage-ios
//
//  Created by Charlie White on 2/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AFRESTfulCoreDataBackgroundQueue.h"
#import "SLRESTfulCoreData.h"
#import "AFNetworking.h"

@interface TRBackgroundQueue : AFRESTfulCoreDataBackgroundQueue

@end

/**
 @abstract  Singleton category
 */
@interface TRBackgroundQueue (Singleton)

+ (TRBackgroundQueue *)sharedInstance;

@end
