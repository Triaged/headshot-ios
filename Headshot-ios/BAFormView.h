//
//  BAFormView.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/7/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BAFormView : UIView

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title placeholder:(NSString *)placeholder;

@end
