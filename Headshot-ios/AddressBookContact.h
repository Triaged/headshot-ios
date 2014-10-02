//
//  AddressBookContact.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/16/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AddressBookContact : NSObject

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSArray *phoneNumbers;
@property (strong, nonatomic) NSArray *emails;
@property (readonly) NSString *displayedTitle;

- (instancetype)initWithRecord:(ABRecordRef)record;

@end
