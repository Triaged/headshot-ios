//
//  OnboardAddPhotoViewController.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 7/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "OnboardAddPhotoViewController.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "PhotoManager.h"
#import "EditAvatarImageView.h"
#import "User.h"

@interface OnboardAddPhotoViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) EditAvatarImageView *avatarImageView;
@property (strong, nonatomic) UIButton *addPhotoButton;

@end

@implementation OnboardAddPhotoViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skipButtonTouched:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.avatarImageView = [[EditAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 105, 105)];
    self.avatarImageView.y = 46;
    self.avatarImageView.centerX = self.view.width/2.0;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width/2.0;
    self.avatarImageView.clipsToBounds = YES;
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotoButtonTouched:)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:avatarTap];
    [self.view addSubview:self.avatarImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.size = CGSizeMake(self.view.width, 35);
    self.titleLabel.y = 194;
    self.titleLabel.textColor = [[ThemeManager sharedTheme] greenColor];
    self.titleLabel.font = [ThemeManager regularFontOfSize:23];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.size = CGSizeMake(180, 54);
    detailLabel.centerX = self.view.width/2.0;
    detailLabel.y = 225;
    detailLabel.text = @"Add a profile photo so coworkers can recognize you.";
    detailLabel.textColor = [[ThemeManager sharedTheme] lightGrayTextColor];
    detailLabel.font = [ThemeManager regularFontOfSize:14];
    detailLabel.numberOfLines = 2;
    detailLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:detailLabel];
    
    
    self.addPhotoButton = [[UIButton alloc] init];
    self.addPhotoButton.size = CGSizeMake(self.view.width, 60);
    self.addPhotoButton.bottom = self.view.height;
    self.addPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.addPhotoButton.backgroundColor = [[ThemeManager sharedTheme] orangeColor];
    [self.addPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    self.addPhotoButton.titleLabel.font = [ThemeManager regularFontOfSize:18];
    [self.view addSubview:self.addPhotoButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    User *user = [AppDelegate sharedDelegate].store.currentAccount.currentUser;
    self.titleLabel.text = [NSString stringWithFormat:@"Great, %@", user.firstName];
    if (user.avatarUrl) {
        NSURL *url = [NSURL URLWithString:user.avatarUrl];
        [self.avatarImageView.imageView setImageWithURL:url];
        [self configureForEditPhoto];
    }
    else {
        [self configureForAddPhoto];
    }
}

- (void)configureForAddPhoto
{
    self.avatarImageView.addPhotoLabel.text = @"Add Photo";
    [self.addPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    [self.addPhotoButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.addPhotoButton addTarget:self action:@selector(addPhotoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureForEditPhoto
{
    self.avatarImageView.addPhotoLabel.text = @"Edit Photo";
    [self.addPhotoButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.addPhotoButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.addPhotoButton addTarget:self action:@selector(nextButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)skipButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:skipButtonTouched:)]) {
        [self.delegate onboardViewController:self skipButtonTouched:sender];
    }
}

- (void)nextButtonTouched:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onboardViewController:doneButtonTouched:)]) {
        [self.delegate onboardViewController:self doneButtonTouched:sender];
    }
}

- (void)addPhotoButtonTouched:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Add a Photo"];
    [actionSheet bk_addButtonWithTitle:@"Add From Library" handler:^{
        [self presentImagePickerOfType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [actionSheet bk_addButtonWithTitle:@"Take Photo" handler:^{
        [self presentImagePickerOfType:UIImagePickerControllerSourceTypeCamera];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:self.view];
}

- (void)presentImagePickerOfType:(UIImagePickerControllerSourceType)pickerSourceType
{
    [[PhotoManager sharedManager] presentImagePickerForSourceType:pickerSourceType fromViewController:self completion:^(UIImage *image, BOOL cancelled) {
        if (image) {
            UIImage *currentImage = self.avatarImageView.imageView.image;
            self.avatarImageView.imageView.image = image;
            [SVProgressHUD show];
            [[AppDelegate sharedDelegate].store.currentAccount updateAvatarImage:image withCompletion:^(UIImage *image, NSError *error) {
                [SVProgressHUD dismiss];
                if (error) {
                    self.avatarImageView.imageView.image = currentImage;
                }
                if (self.avatarImageView.imageView.image) {
                    [self configureForEditPhoto];
                }
            }];
        }
    }];
}

@end
