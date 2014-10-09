//
//  JAKeyboardObserver.m
//  SideBar
//
//  Created by Jeffrey Ames on 9/24/14.
//  Copyright (c) 2014 sidebar. All rights reserved.
//

#import "JAKeyboardObserver.h"

@implementation JAKeyboardInfo

- (instancetype)initWithNotification:(NSNotification *)notification
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSDictionary *userInfo = notification.userInfo;
    self.frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.notificationName = notification.name;
    
    return self;
}

@end

@implementation JAKeyboardObserver

- (instancetype)initWithDelegate:(id<JAKeyboardObserverDelegate>)delegate
{
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ja_didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ja_didReceiveKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ja_didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ja_didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ja_didReceiveKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ja_didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ja_didReceiveKeyboardWillShowNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)ja_didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)ja_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)ja_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)ja_didReceiveKeyboardWillHideNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)ja_didReceiveKeyboardDidHideNotification:(NSNotification *)notification
{
    [self updateDelegateWithKeyboardInfo:[[JAKeyboardInfo alloc] initWithNotification:notification]];
}

- (void)updateDelegateWithKeyboardInfo:(JAKeyboardInfo *)keyboardInfo
{
    NSString *notificationName = keyboardInfo.notificationName;
    if ([notificationName isEqualToString:UIKeyboardWillShowNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedWillShowNotificationWithInfo:)]) {
            [self.delegate performSelector:@selector(keyboardObserver:receivedWillShowNotificationWithInfo:) withObject:self withObject:keyboardInfo];
        }
    }
    else if ([notificationName isEqualToString:UIKeyboardDidShowNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedDidShowNotificationWithInfo:)]) {
            [self.delegate keyboardObserver:self receivedDidShowNotificationWithInfo:keyboardInfo];
        }
    }
    else if ([notificationName isEqualToString:UIKeyboardWillHideNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedWillHideNotificationWithInfo:)]) {
            [self.delegate keyboardObserver:self receivedWillHideNotificationWithInfo:keyboardInfo];
        }
    }
    else if ([notificationName isEqualToString:UIKeyboardDidHideNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedDidHideNotificationWithInfo:)]) {
            [self.delegate keyboardObserver:self receivedDidHideNotificationWithInfo:keyboardInfo];
        }
    }
    else if ([notificationName isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedWillChangeFrameNotificationWithInfo:)]) {
            [self.delegate keyboardObserver:self receivedWillChangeFrameNotificationWithInfo:keyboardInfo];
        }
    }
    else if ([notificationName isEqualToString:UIKeyboardDidChangeFrameNotification]) {
        if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedDidChangeFrameNotificationWithInfo:)]) {
            [self.delegate keyboardObserver:self receivedDidChangeFrameNotificationWithInfo:keyboardInfo];
        }
    }
    if ([self.delegate respondsToSelector:@selector(keyboardObserver:receivedNotificationWithInfo:)]) {
        [self.delegate keyboardObserver:self receivedNotificationWithInfo:keyboardInfo];
    }
}

@end
