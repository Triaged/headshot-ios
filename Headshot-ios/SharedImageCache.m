//
//  SharedImageCache.m
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "SharedImageCache.h"
#import "AFNetworking.h"

@implementation SharedImageCache

+ (instancetype)sharedClient {
    static SharedImageCache *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SharedImageCache alloc] init];
    });
    
    return _sharedClient;
}


- (void) configureFastImageCache {
    FICImageFormat *smallUserThumbnailImageFormat = [[FICImageFormat alloc] init];
    smallUserThumbnailImageFormat.name = XXImageFormatNameUserThumbnailSmall;
    smallUserThumbnailImageFormat.family = XXImageFormatFamilyUserThumbnails;
    smallUserThumbnailImageFormat.imageSize = CGSizeMake(50, 50);
    smallUserThumbnailImageFormat.maximumCount = 1000;
    smallUserThumbnailImageFormat.devices = FICImageFormatDevicePhone;
    smallUserThumbnailImageFormat.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *largeUserThumbnailImageFormat = [[FICImageFormat alloc] init];
    largeUserThumbnailImageFormat.name = XXImageFormatNameUserThumbnailLarge;
    largeUserThumbnailImageFormat.family = XXImageFormatFamilyUserThumbnails;
    largeUserThumbnailImageFormat.imageSize = CGSizeMake(100, 100);
    largeUserThumbnailImageFormat.maximumCount = 1000;
    largeUserThumbnailImageFormat.devices = FICImageFormatDevicePhone;
    largeUserThumbnailImageFormat.protectionMode = FICImageFormatProtectionModeNone;
    
    NSArray *imageFormats = @[smallUserThumbnailImageFormat, largeUserThumbnailImageFormat];
    
    self.cache = [FICImageCache sharedImageCache];
    self.cache.delegate = self;
    self.cache.formats = imageFormats;
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Fetch the desired source image by making a network request
        NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:requestURL]];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Response: %@", responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock((UIImage *)responseObject);
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
        
        
    });
}

@end
