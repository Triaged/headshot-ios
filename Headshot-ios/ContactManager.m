//
//  ContactManager.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ContactManager.h"
#import "AddressBookContact.h"

@interface ContactManager()

@end

@implementation ContactManager

+ (ContactManager *)sharedManager
{
    static ContactManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [ContactManager new];
        
    });
    return _sharedManager;
}

- (ABAuthorizationStatus)authorizationStatus
{
    return ABAddressBookGetAuthorizationStatus();
}

- (void)requestContactPermissions:(void (^)())success failure:(void (^)(NSError *error))failure
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                if (success) {
                    success();
                }
            } else {
                if (failure) {
                    failure(nil);
                }
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        if (success) {
            success();
        }
    }
    else {
        if (failure) {
            failure(nil);
        }
    }
}

- (void)fetchAddressBookContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure
{
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    failure((__bridge NSError *)error);
                } else {
                    NSArray *contacts = [self addressBookContacts:addressBook];
                    success(contacts);
                }
            });
        });
    }
}

- (NSArray *)addressBookContacts:(ABAddressBookRef)addressBook
{
    NSMutableArray *contacts = [NSMutableArray new];
    CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int numPeople = ABAddressBookGetPersonCount(addressBook);
    for(int i = 0;i<numPeople;i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        AddressBookContact *contact = [[AddressBookContact alloc] initWithRecord:person];
        [contacts addObject:contact];
    }
    return [NSArray arrayWithArray:contacts];
}

@end
