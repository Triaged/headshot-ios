//
//  LoginViewController.m
//  Docked-ios
//
//  Created by Charlie White on 9/21/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "LoginViewController.h"
#import "HeadshotAPIClient.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField, loginButton, triangeImage, logoLabel, divider1, divider2, backButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = [AppDelegate sharedDelegate].window.frame;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        //self.triangeImage.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    loginButton.backgroundColor = [[UIColor alloc] initWithRed:121.0f/255.0f green:147.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
    [loginButton.layer setCornerRadius:3.0f];
    [loginButton.layer setMasksToBounds:YES];
    
    UIColor *color = [[UIColor alloc] initWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
;
    usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Work Email" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: @"Avenir-light"}];


    passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: @"Avenir-light"}];
    
    divider2.hidden = YES;

}

//-(void) viewDidAppear:(BOOL)animated {
//    [usernameTextField becomeFirstResponder];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login {
    [SVProgressHUD show];
    
    id params = @{@"user_login" : @{
                  @"email": self.usernameTextField.text,
                  @"password": self.passwordTextField.text
                  }};
    
    [[HeadshotAPIClient sharedClient] POST:@"sessions.json" parameters:params success:^(NSURLSessionDataTask *task, id JSON) {
        
        // Set Auth Code
        NSString *authToken = [JSON valueForKeyPath:@"authentication_token"];
        [[CredentialStore sharedClient] setAuthToken:authToken];
        
        // Get the Current Account
       [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:self];
        
        [SVProgressHUD dismiss];
        //[welcomeVC dismissAuthScreens:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = [error.userInfo objectForKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
        if (response.statusCode == 500) {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong. Please try again."];
        } else {
            NSString *errorMessage = [error.userInfo objectForKey:@"JSONResponseSerializerWithDataKey"];
            [SVProgressHUD showErrorWithStatus:errorMessage];
        }
    }];
}

- (IBAction)returnToWelcome:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)resetPassword:(id)sender {
//    ResetPasswordViewController *resetVC = [[ResetPasswordViewController alloc] init];
//    [self presentViewController:resetVC animated:YES completion:nil];
//}

-(void)keyboardWillShow:(NSNotification*)notification  {
    
    NSDictionary *userInfo = notification.userInfo;
    
    //
    // Get keyboard size.
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    //
    // Get keyboard animation.
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    //
    // Create animation.
    void (^animations)() = ^() {
        
       
        
        // Logo
        CGRect logoFrame = logoLabel.frame;
        logoFrame.origin.y = 30;
        logoLabel.frame = logoFrame;
        
        //Subtext
        triangeImage.hidden = YES;
        if (!IS_IPHONE5) logoLabel.hidden = YES;
        
        
        // Fields
        CGRect usernameFrame = usernameTextField.frame;
        CGRect passwordFrame = passwordTextField.frame;
        CGRect divider1Frame = divider1.frame;
        
        CGRect divider2Frame = divider2.frame;
        if (IS_IPHONE5) {
            loginButton.frame = CGRectMake(loginButton.frame.origin.x, loginButton.frame.origin.y-keyboardEndFrame.size.height, loginButton.frame.size.width, loginButton.frame.size.height);
            
            usernameFrame.origin.y = usernameFrame.origin.y - keyboardEndFrame.size.height;
            passwordFrame.origin.y = passwordFrame.origin.y - keyboardEndFrame.size.height;
            divider1Frame.origin.y = divider1Frame.origin.y - keyboardEndFrame.size.height;
            divider2Frame.origin.y = divider2Frame.origin.y - keyboardEndFrame.size.height;
        } else {
            
            loginButton.frame = CGRectMake(loginButton.frame.origin.x, loginButton.frame.origin.y-150, loginButton.frame.size.width, loginButton.frame.size.height);
            
            
            usernameFrame.origin.y = usernameFrame.origin.y - 150;
            passwordFrame.origin.y = passwordFrame.origin.y - 150;
            divider1Frame.origin.y = divider1Frame.origin.y - 150;
            divider2Frame.origin.y = divider2Frame.origin.y - 150;

        }
        
        usernameTextField.frame = usernameFrame;
        passwordTextField.frame = passwordFrame;
        divider1.frame = divider1Frame;
        divider2.frame = divider2Frame;
    };
    
    
    //
    // Begin animation.
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:NULL];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
}


@end
