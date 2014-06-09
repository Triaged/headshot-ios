//
//  LoginViewController.h
//  Docked-ios
//
//  Created by Charlie White on 9/21/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CredentialStore.h"


@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *triangeImage;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIImageView *divider2;
@property (weak, nonatomic) IBOutlet UIImageView *divider1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomBottomConstraint;

- (IBAction)login;
- (IBAction)returnToWelcome:(id)sender;
- (IBAction)resetPassword:(id)sender;

@end
