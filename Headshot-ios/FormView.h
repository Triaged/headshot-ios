//
//  FormView.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/15/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormView : UIView

- (id)initWithFieldName:(NSString *)fieldName placeholder:(NSString *)placeholder;

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSString *fieldName;

@end
