//
//  CodeInputView.m
//  Headshot-ios
//
//  Created by Jeffrey Ames on 10/1/14.
//  Copyright (c) 2014 Charlie White. All rights reserved.
//

#import "CodeInputView.h"
#import "UIControl+NextControl.h"

@protocol CodeTextFieldDelegate <NSObject, UITextFieldDelegate>

- (void)textFieldDidDelete:(UITextField *)textField;

@end

@interface CodeTextField : UITextField

@property (weak, nonatomic) id<CodeTextFieldDelegate>delegate;

@end

@implementation CodeTextField

- (void)deleteBackward {
    [super deleteBackward];
    
    if ([self.delegate respondsToSelector:@selector(textFieldDidDelete:)]){
        [self.delegate textFieldDidDelete:self];
    }
}

//ios 8 bug: http://stackoverflow.com/questions/25354467/detect-backspace-in-uitextfield-in-ios8
- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    if (![textField.text length] && [[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}

@end

@interface CodeInputView() <CodeTextFieldDelegate>

@property (assign, nonatomic) CGFloat gap;

@end

@implementation CodeInputView

- (instancetype)initWithCellSize:(CGSize)size horizontalGap:(CGFloat)horizontalGap codeLength:(NSInteger)codeLength
{
    CGRect frame = CGRectZero;
    frame.size.width = size.width*codeLength + horizontalGap*(codeLength - 1);
    frame.size.height = size.height;
    self = [self initWithFrame:frame];
    _codeLength = codeLength;
    _cellSize = size;
    self.gap = horizontalGap;
    [self configure];
    
    return self;
}

- (void)becomeFirstResponder
{
    UITextField *textField = [self.textFields firstObject];
    [textField becomeFirstResponder];
}

- (void)clear
{
    for (UITextField *textField in self.textFields) {
        textField.text = nil;
    }
    [self becomeFirstResponder];
}

- (void)configure
{
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    for (NSInteger i=0;i<_codeLength;i++) {
        UITextField *textField = [[CodeTextField alloc] init];
        [self addSubview:textField];
        textField.delegate = self;
        textField.size = _cellSize;
        textField.x = i*_cellSize.width + i*self.gap;
        textField.layer.borderColor = [UIColor grayColor].CGColor;
        textField.layer.borderWidth = 1;
        textField.layer.cornerRadius = 4;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        [textFields addObject:textField];
        if (i>0) {
            UITextField *previous = textFields[i - 1];
            previous.nextControl = textField;
        }
    }
    _textFields = [NSArray arrayWithArray:textFields];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    for (UITextField *textField in self.textFields) {
        textField.font = font;
    }
}

- (NSString *)code
{
    NSMutableString *code = [[NSMutableString alloc] init];
    for (UITextField *textField in self.textFields) {
        if (textField.text.length == 1) {
            [code appendString:textField.text];
        }
        else {
            return nil;
        }
    }
    return code;
}

- (void)finishedEnteringCode
{
    if ([self.delegate respondsToSelector:@selector(codeInputView:didFinishEnteringCode:)]) {
        [self.delegate codeInputView:self didFinishEnteringCode:self.code];
    }
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.nextControl) {
        [textField.nextControl becomeFirstResponder];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length == 0) {
        return YES;
    }
    if (newString.length == 1) {
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.nextControl) {
        [textField.nextControl becomeFirstResponder];
    }
    else {
        [self finishedEnteringCode];
    }
}

- (void)textFieldDidDelete:(UITextField *)textField
{
    if (textField.previousControl) {
        UITextField *previousTextField = (UITextField *)textField.previousControl;
        previousTextField.text = nil;
        [textField.previousControl becomeFirstResponder];
    }
}

@end
