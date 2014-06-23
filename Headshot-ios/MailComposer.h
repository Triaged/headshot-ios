//
//  MailComposer.h
//  Headshot-ios
//
//  Created by Charlie White on 6/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MailComposer : NSObject

+ (MFMailComposeViewController *)sharedComposer;

@end
