//
//  MessageThread+RecipientsExcludeCurrent.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThread+RecipientsExcludeCurrent.h"

@implementation MessageThread (RecipientsExcludeCurrent)

- (NSSet *)recipientsExcludeUser
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier != %@", [AppDelegate sharedDelegate].store.currentAccount.identifier];
    return [self.recipients filteredSetUsingPredicate:predicate];
}

@end
