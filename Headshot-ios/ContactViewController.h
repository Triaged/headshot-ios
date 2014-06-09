//
//  ContactViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 5/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController : UIViewController <MFMailComposeViewControllerDelegate, UIToolbarDelegate>

@property (strong, nonatomic) User *user;


@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentOfficeLocationLabel;

- (id)initWitUser:(User *)theUser;

- (IBAction)meetTapped:(id)sender;
- (IBAction)callTapped:(id)sender;
- (IBAction)messageTapped:(id)sender;
- (IBAction)emailTapped:(id)sender;
@end
