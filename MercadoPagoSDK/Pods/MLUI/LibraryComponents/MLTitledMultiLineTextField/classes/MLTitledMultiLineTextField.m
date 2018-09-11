//
// MLTitledMultiLineTextField.m
// MLUI
//
// Created by Juan Andres Gebhard on 5/17/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLTitledMultiLineTextField.h"
#import "UIFont+MLFonts.h"
#import "MLStyleSheetManager.h"

@interface MLTitledMultiLineTextField () <UITextViewDelegate>

@property (weak, nonatomic) UITextView *textView;

@property (nonatomic, copy) NSString *textCache;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat maximumTextHeight;

@property (nonatomic, assign) BOOL disableStyling;

@end

@implementation MLTitledMultiLineTextField

#pragma mark Style

- (void)style
{
	if (self.disableStyling) {
		return;
	}

	[super style];

	UIColor *textColor = MLStyleSheetManager.styleSheet.blackColor;
	UIColor *lineColor = MLStyleSheetManager.styleSheet.midGreyColor;
	switch (self.state) {
		case MLTitledTextFieldStateDisabled: {
			textColor = MLStyleSheetManager.styleSheet.midGreyColor;
			break;
		}

		case MLTitledTextFieldStateEditing: {
			lineColor = MLStyleSheetManager.styleSheet.secondaryColor;
			break;
		}

		case MLTitledTextFieldStateError: {
			lineColor = MLStyleSheetManager.styleSheet.errorColor;
			break;
		}

		default: {
			break;
		}
	}

	if (!self.textCache.length) {
		textColor = MLStyleSheetManager.styleSheet.midGreyColor;
	}

	__weak typeof(self)weakSelf = self;

	[UIView animateWithDuration:.5f animations: ^{
	    weakSelf.textView.textColor = textColor;

	    /**
	     * UITextView doesn't change its tint color when it is the first responder.
	     * So we have to make it resign and then become first responder again in order to force
	     * the color change to take place.
	     */
	    if (![lineColor isEqual:weakSelf.textView.tintColor]) {
	        weakSelf.textView.tintColor = lineColor;

	        if (weakSelf.isFirstResponder) {
	            weakSelf.disableStyling = YES;
	            [UIView setAnimationsEnabled:NO];
	            [weakSelf resignFirstResponder];
	            [weakSelf becomeFirstResponder];
	            [UIView setAnimationsEnabled:YES];
	            weakSelf.disableStyling = NO;
			}
		}
	}];
}

- (void)updateTextViewHeight
{
	CGSize textViewSize = self.textView.frame.size;
	textViewSize.height = MAXFLOAT;
	CGSize textSize = [self sizeForText:self.text];

	if (self.scrollEnabled && self.maxLines) {
		CGFloat maxHeight = self.maxLines * self.lineHeight;
		textSize.height = MIN(textSize.height, maxHeight);
	}

	[self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
	CGFloat viewSize = self.frame.size.height;
	CGFloat textInputSize = self.textInputControl.frame.size.height;
	CGFloat delta = viewSize - textInputSize;

	CGSize textSize = [self sizeForText:self.text];

	if (self.maxLines) {
		textSize.height = MIN(textSize.height, self.maximumTextHeight);
	}

	CGSize intrinsicSize = CGSizeMake(textSize.width, textSize.height + delta);

	return intrinsicSize;
}

#pragma mark Custom Setters

- (void)setText:(NSString *)text
{
	if (![self validateLength:text]) {
		return;
	}
	self.textCache = text;
	self.textView.text = text;
	[self style];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
	self.textView.keyboardType = keyboardType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
	self.textView.autocapitalizationType = autocapitalizationType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
	self.textView.autocorrectionType = autocorrectionType;
}

- (void)setMaxLines:(NSUInteger)maxLines
{
	_maxLines = maxLines;
	self.maximumTextHeight = maxLines * self.lineHeight;
}

/**
 *  TODO :
 *
 *  Not sure if this setter has correct funcionality, what if you want an ammount of lines but the widget is smaller than expected ? then
 *  you will need scrolling to be enable and also a maximumNumberOfLines.
 **/
- (void)setScrollEnabled:(BOOL)scrollEnabled
{
	self.textView.scrollEnabled = scrollEnabled;
}

- (BOOL)isScrollEnabled
{
	return self.textView.scrollEnabled;
}

#pragma mark Custom Getters

- (NSString *)text
{
	return self.textCache ? : @"";
}

- (UIKeyboardType)keyboardType
{
	return self.textView.keyboardType;
}

- (UITextAutocapitalizationType)autocapitalizationType
{
	return self.textView.autocapitalizationType;
}

- (UITextAutocorrectionType)autocorrectionType
{
	return self.textView.autocorrectionType;
}

- (CGFloat)lineHeight
{
	if (_lineHeight) {
		return _lineHeight;
	}
	_lineHeight = [self sizeForText:@" "].height;
	return _lineHeight;
}

- (UIView <UITextInputTraits, UITextInput> *)textInputControl
{
	return self.textView;
}

- (UITextView *)textView
{
	if (_textView) {
		return _textView;
	}

	UITextView *textView = [[UITextView alloc] init];
	textView.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeMedium];

	textView.delegate = self;
	textView.scrollEnabled = NO;
	textView.showsVerticalScrollIndicator = textView.showsHorizontalScrollIndicator = NO;
	textView.textContainer.lineFragmentPadding = 0;
	textView.textContainerInset = UIEdgeInsetsZero;
	textView.backgroundColor = [UIColor clearColor];

	_textView = textView;
	return _textView;
}

- (BOOL)scrollEnabled
{
	return self.textView.scrollEnabled;
}

#pragma mark Text size calculations

- (CGSize)sizeForText:(NSString *)text
{
	NSDictionary *attributes = self.textView.font ? @{NSFontAttributeName : self.textView.font} : nil;
	CGSize textViewSize = CGSizeMake(CGRectGetWidth(self.textView.frame), MAXFLOAT);
	CGRect textRect = [text boundingRectWithSize:textViewSize
	                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
	                                  attributes:attributes
	                                     context:nil];

	return textRect.size;
}

#pragma mark TextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	self.textCache = textView.text;
	[self updateTextViewHeight];
	[self style];
	[self sendActionsForControlEvents:UIControlEventEditingChanged];

	[self.textView layoutIfNeeded];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	self.textView.text = self.textCache;
	[self style];
	if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		[self.delegate textFieldDidBeginEditing:self];
	}
	[self sendActionsForControlEvents:UIControlEventEditingDidBegin];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	[self style];
	if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
		[self.delegate textFieldDidEndEditing:self];
	}
	[self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	self.textView.layoutManager.allowsNonContiguousLayout = NO;

	NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
	CGSize finalStringSize = [self sizeForText:finalString];
	if (!self.scrollEnabled && self.maxLines && finalStringSize.height > self.maximumTextHeight) {
		return NO;
	}
	if (![self validateLength:finalString]) {
		return NO;
	}
	if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
		[self.delegate textField:self shouldChangeCharactersInRange:range replacementString:text];
	}

	if ([text isEqualToString:@"\n"] &&
	    [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
		return [self.delegate textFieldShouldReturn:self];
	}
	return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
		return [self.delegate textFieldShouldBeginEditing:self];
	}
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
		return [self.delegate textFieldShouldEndEditing:self];
	}
	return YES;
}

#pragma mark UIResponder

- (BOOL)isFirstResponder
{
	return self.textView.isFirstResponder;
}

- (BOOL)becomeFirstResponder
{
	return self.textView.becomeFirstResponder;
}

- (BOOL)canBecomeFirstResponder
{
	return self.textView.canBecomeFirstResponder;
}

- (BOOL)resignFirstResponder
{
	return self.textView.resignFirstResponder;
}

- (BOOL)canResignFirstResponder
{
	return self.textView.canResignFirstResponder;
}

#pragma mark Validations

- (BOOL)validateLength:(NSString *)string
{
	return !(self.maxCharacters && string.length > self.maxCharacters);
}

#pragma mark KVO

+ (NSSet *)keyPathsForValuesAffectingText
{
	NSSet *keyPaths = [NSSet setWithObject:NSStringFromSelector(@selector(textCache))];
	return keyPaths;
}

@end
