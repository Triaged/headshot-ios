//
//  TRKeyboardAccessoryView.h
//  Headshot-ios
//
//  Created by Jeffrey Ames on 6/25/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRKeyboardAccessoryView : UIView

- (id)initWithCancel:(void (^)())cancelBlock doneBlock:(void (^)())doneBlock;

@end
