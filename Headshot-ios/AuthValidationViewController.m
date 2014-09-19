//
//  AuthValidationViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 9/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "AuthValidationViewController.h"
#import "HeadshotAPIClient.h"

@interface AuthValidationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *activationCodeTextField;

@end

@implementation AuthValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.activationCodeTextField = [[UITextField alloc] init];
    [self.view addSubview:self.activationCodeTextField];
    self.activationCodeTextField.size = CGSizeMake(200, 100);
    self.activationCodeTextField.centerX = self.view.width/2.0;
    self.activationCodeTextField.y = 100;
    self.activationCodeTextField.placeholder = @"Activation Code";
    self.activationCodeTextField.delegate = self;
}

- (void)activate
{
    NSString *code = self.activationCodeTextField.text;
    NSDictionary *parameters = @{@"auth_params" : @{
                                         @"id" : self.userIdentifier,
                                         @"challenge_code" : code
                                         }};
    [[HeadshotAPIClient sharedClient] POST:@"authentications/valid" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self activate];
    return YES;
}

@end
