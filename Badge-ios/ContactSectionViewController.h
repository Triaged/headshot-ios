//
//  ContactSectionViewController.h
//  Headshot-ios
//
//  Created by Charlie White on 6/11/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSectionViewController : UIViewController

@property (strong, nonatomic) NSString *sectionText;
@property (strong, nonatomic) IBOutlet UILabel *sectionHeaderLabel;

- (id)initWithText:(NSString *)text;

@end
