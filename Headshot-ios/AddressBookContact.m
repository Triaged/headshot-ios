//
//  AddressBookContact.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AddressBookContact.h"

@implementation AddressBookContact

- (instancetype)initWithRecord:(ABRecordRef)record
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSString *fullName = (__bridge NSString *)(ABRecordCopyCompositeName(record));
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(record,
                                                                         kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(record,
                                                                        kABPersonLastNameProperty);
    
    self.fullName = fullName;
    self.firstName = firstName;
    self.lastName = lastName;
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(record,
                                                     kABPersonPhoneProperty);
    
    NSMutableArray *phoneNumbersMutable = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *number = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
        [phoneNumbersMutable addObject:number];
    }
    CFRelease(phoneNumbers);
    self.phoneNumbers = [NSArray arrayWithArray:phoneNumbersMutable];
    ABMutableMultiValueRef emails = ABRecordCopyValue(record, kABPersonEmailProperty);
    NSMutableArray *emailsMutable = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<ABMultiValueGetCount(emails); i++) {
        NSString *email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emails, i));
        [emailsMutable addObject:email];
    }
    CFRelease(emails);
    self.emails = [NSArray arrayWithArray:emailsMutable];
    return self;
}

- (NSString *)displayedTitle
{
    NSString *title;
    if (self.fullName) {
        title = self.fullName;
    }
    else if (self.emails && self.emails.count) {
        title = [self.emails firstObject];
    }
    return title;
}

@end
