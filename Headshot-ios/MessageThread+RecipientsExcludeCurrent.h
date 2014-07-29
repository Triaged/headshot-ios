//
//  MessageThread+RecipientsExcludeCurrent.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThread.h"
#import "User.h"

@interface MessageThread (RecipientsExcludeCurrent)


- (NSSet *)recipientsExcludeUser;
- (BOOL)isGroupThread;

/**
Recipient of a direct message with the current user. If the thread is a group message thread this is nil.
 */
- (User *)directMessageRecipient;



@end
