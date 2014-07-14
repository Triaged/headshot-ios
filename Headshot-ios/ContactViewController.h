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
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "TRAvatarImageView.h"

@interface ContactViewController : UIViewController <MFMailComposeViewControllerDelegate, UIToolbarDelegate, EKEventEditViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) User *user;


@property (strong, nonatomic) IBOutlet TRAvatarImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentOfficeLocationLabel;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UILabel *callLabel;
@property (strong, nonatomic) IBOutlet UITableView *contactDetailsTableView;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstraint;

- (id)initWitUser:(User *)theUser;

- (IBAction)meetTapped:(id)sender;
- (IBAction)callTapped:(id)sender;
- (IBAction)messageTapped:(id)sender;
- (IBAction)emailTapped:(id)sender;
@end