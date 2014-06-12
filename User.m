//
//  User.m
//  Headshot-ios
//
//  Created by Charlie White on 5/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "User.h"
#import "Company.h"
#import "EmployeeInfo.h"
#import "FICUtilities.h"


@implementation User

@dynamic identifier;
@dynamic firstName;
@dynamic lastName;
@dynamic name;
@dynamic email;
@dynamic avatarFaceUrl;
@dynamic avatarUrl;
@dynamic employeeInfo;
@dynamic company;
@dynamic manager;
@dynamic subordinates;

+ (void)usersWithCompletionHandler:(void(^)(NSArray *users, NSError *error))completionHandler {
    NSURL *URL = [NSURL URLWithString:@"users.json"];
    [self fetchObjectsFromURL:URL completionHandler:completionHandler];
}

- (NSString *)UUID {
    CFUUIDBytes UUIDBytes = FICUUIDBytesWithString(self.identifier);
    NSString *UUID = FICStringWithUUIDBytes(UUIDBytes);
    
    return UUID;
   
}

- (NSString *)sourceImageUUID {
    CFUUIDBytes sourceImageUUIDBytes = FICUUIDBytesWithString(self.avatarUrl);
    NSString *sourceImageUUID = FICStringWithUUIDBytes(sourceImageUUIDBytes);
    
    return sourceImageUUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    return [NSURL URLWithString:self.avatarUrl];
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        
//        // Clip medium thumbnails so they have rounded corners
//        if ([formatName isEqualToString:XXImageFormatNameUserThumbnailMedium]) {
//            UIBezierPath clippingPath = [self _clippingPath];
//            [clippingPath addClip];
//        }
        
        UIGraphicsPushContext(context);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

-(void)fetchOrgStructure {
    NSURL *managerURL = [NSURL URLWithString:[NSString stringWithFormat:@"users/%@/manager", self.identifier]];
    [self fetchObjectsForRelationship:@"manager" fromURL:managerURL completionHandler:^(NSArray *fetchedObjects, NSError *error) {}];
    
    NSURL *subordinatesURL = [NSURL URLWithString:[NSString stringWithFormat:@"users/%@/subordinates", self.identifier]];
    [self fetchObjectsForRelationship:@"subordinates" fromURL:subordinatesURL completionHandler:^(NSArray *fetchedObjects, NSError *error) {}];

}


@end
