//
//  MailComposer.m
//  Headshot-ios
//
//  Created by Charlie White on 6/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MailComposer.h"

@implementation MailComposer


+ (MFMailComposeViewController *)sharedComposer {
    static MFMailComposeViewController *composeViewController = nil;
    composeViewController  = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    return composeViewController;
}

@end
