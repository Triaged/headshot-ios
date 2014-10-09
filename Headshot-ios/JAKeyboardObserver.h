//
//  JAKeyboardObserver.h
//  SideBar
//
//  Created by Jeffrey Ames on 9/24/14.
//  Copyright (c) 2014 sidebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAKeyboardInfo : NSObject

@property (assign, nonatomic) CGRect frameBegin;
@property (assign, nonatomic) CGRect frameEnd;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) UIViewAnimationCurve animationCurve;
@property (strong, nonatomic) NSString *notificationName;

@end

@class JAKeyboardObserver;
@protocol JAKeyboardObserverDelegate <NSObject>

@optional
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillShowNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedDidShowNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillChangeFrameNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedDidChangeFrameNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedWillHideNotificationWithInfo:(JAKeyboardInfo *)info;
- (void)keyboardObserver:(JAKeyboardObserver *)observer receivedDidHideNotificationWithInfo:(JAKeyboardInfo *)info;

@end

@interface JAKeyboardObserver : NSObject

@property (weak, nonatomic) id<JAKeyboardObserverDelegate> delegate;

- (instancetype)initWithDelegate:(id<JAKeyboardObserverDelegate>)delegate;


@end
