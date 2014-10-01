//
//  AuthValidationViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AuthValidationViewController.h"
#import "HeadshotAPIClient.h"
#import "CodeInputView.h"

@interface AuthValidationViewController () <UITextFieldDelegate, CodeInputViewDelegate>

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UITextField *activationCodeTextField;
@property (strong, nonatomic) CodeInputView *codeInputView;

@end

@implementation AuthValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Verify Email";
    
    self.label = [[UILabel alloc] init];
    [self.view addSubview:self.label];
    self.label.width = 256;
    self.label.centerX = self.view.width/2.0;
    self.label.y = 24;
    self.label.text = @"We have sent you an email with a verification code. Please enter the 4-digit validation code.";
    self.label.numberOfLines = 0;
    self.label.font = [ThemeManager lightFontOfSize:18];
    self.label.textColor = [UIColor colorWithRed:131/255.0 green:137/255.0 blue:148/255.0 alpha:1.0];
    [self.label sizeToFit];

    self.codeInputView = [[CodeInputView alloc] initWithCellSize:CGSizeMake(63, 57) horizontalGap:8 codeLength:4];
    [self.view addSubview:self.codeInputView];
    self.codeInputView.delegate = self;
    self.codeInputView.font = [ThemeManager regularFontOfSize:30];
    self.codeInputView.y = self.label.bottom + 45;
    self.codeInputView.centerX = self.view.width/2.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)activateWithCode:(NSString *)code
{
    NSDictionary *parameters = @{@"auth_params" : @{
                                         @"id" : self.userIdentifier,
                                         @"challenge_code" : code
                                         }};
    [[HeadshotAPIClient sharedClient] POST:@"authentications/valid" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.codeInputView clear];
        [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)codeInputView:(CodeInputView *)codeInputView didFinishEnteringCode:(NSString *)code
{
    [self activateWithCode:code];
}

@end
