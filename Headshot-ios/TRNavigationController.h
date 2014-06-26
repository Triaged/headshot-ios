//
//  TRNavigationViewController.h
//  Triage-ios
//
//  Created by Charlie White on 11/5/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (strong, nonatomic)  UIProgressView *progress;

-(void)popToRoot;


@end
