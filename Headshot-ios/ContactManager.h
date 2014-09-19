//
//  ContactManager.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class Group;
@interface ContactManager : NSObject

@property (readonly) ABAuthorizationStatus authorizationStatus;

+ (ContactManager *)sharedManager;
- (void)requestContactPermissions:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)fetchAddressBookContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure;

@end