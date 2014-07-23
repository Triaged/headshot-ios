//
//  MessageThread+RecipientsExcludeCurrent.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/23/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "MessageThread.h"

@interface MessageThread (RecipientsExcludeCurrent)

- (NSSet *)recipientsExcludeUser;

@end
