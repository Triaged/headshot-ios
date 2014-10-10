//
//  ReadReceiptCell.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReadReceipt, User;
@interface ReadReceiptCell : UITableViewCell

- (void)configureForReadReceipt:(ReadReceipt *)readReceipt;
- (void)configureForUnreadUser:(User *)user;

@end
