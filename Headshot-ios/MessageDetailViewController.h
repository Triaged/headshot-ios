//
//  MessageDetailViewController.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/10/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageDetailViewController : UITableViewController

- (instancetype)initWithMessage:(Message *)message;

@property (strong, nonatomic) Message *message;

@end
