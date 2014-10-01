//
//  WelcomeViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "WelcomeViewController.h"
#import "RegisterViewController.h"

@interface WelcomeViewController ()

@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize buttonSize = CGSizeMake(300, 43);
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.loginButton];
    self.loginButton.size = buttonSize;
    self.loginButton.bottom = self.view.height - 10;
    self.loginButton.centerX = self.view.width/2.0;
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [ThemeManager lightFontOfSize:16];
    self.loginButton.backgroundColor = [UIColor colorWithRed:202/255.0 green:204/255.0 blue:209/255.0 alpha:1.0];
    self.loginButton.layer.cornerRadius = 4;
    [self.loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:
     UIControlEventTouchUpInside];
    
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.signUpButton];
    self.signUpButton.size = buttonSize;
    self.signUpButton.bottom = self.loginButton.y - 10;
    self.signUpButton.centerX = self.view.width/2.0;
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.signUpButton.backgroundColor = [[ThemeManager sharedTheme] primaryColor];
    self.signUpButton.layer.cornerRadius = self.loginButton.layer.cornerRadius;
    self.signUpButton.titleLabel.font = [ThemeManager lightFontOfSize:16];
    [self.signUpButton addTarget:self action:@selector(signUpButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)loginButtonTouched:(id)sender
{
    
}

- (void)signUpButtonTouched:(id)sender
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    [self presentViewControllerWithNav:registerViewController animated:YES completion:nil];
}

@end
