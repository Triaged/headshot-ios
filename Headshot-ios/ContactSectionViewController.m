//
//  ContactSectionViewController.m
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "ContactSectionViewController.h"

@interface ContactSectionViewController ()

@end

@implementation ContactSectionViewController

- (id)initWithText:(NSString *)text
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.sectionText = text;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sectionHeaderLabel.text = self.sectionText;
    self.view.backgroundColor = [[UIColor alloc] initWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
