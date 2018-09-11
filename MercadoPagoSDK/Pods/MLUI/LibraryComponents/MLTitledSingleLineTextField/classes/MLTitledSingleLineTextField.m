//
// MLTextFieldWithLabel.m
// MLUI
//
// Created by Juan Andres Gebhard on 5/5/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLTitledSingleLineTextField.h"
#import "UIFont+MLFonts.h"
#import "MLUIBundle.h"
#import "MLStyleSheetManager.h"
#import "MLTitledSingleLineStringProvider.h"

static const CGFloat kMLTextFieldThinLine = 1;
static const CGFloat kMLTextFieldThickLine = 2;

@interface MLTitledSingleLineTextField () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIView *textInputContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (weak, nonatomic) IBOutlet UIView *accessoryViewContainer;

@property (strong, nonatomic) UITextField *textField;
@property (copy, nonatomic) NSString *textCache;

@end

@implementation MLTitledSingleLineTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	[self loadFromNib];
	[self addTextInput];
	[self style];
	[self updateCharacterCount];
	[self observeText];
}

- (void)loadFromNib
{
	NSString *nibName = @"MLTitledLineTextField";
	NSArray *nibArray = [[MLUIBundle mluiBundle] loadNibNamed:nibName
	                                                    owner:self
	                                                  options:nil];
	UIView *view = nibArray.firstObject;
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:view];

	NSDictionary *views = @{@"view" : view};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
	                                                             options:0
	                                                             metrics:nil
	                                                               views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
	                                                             options:0
	                                                             metrics:nil
	                                                               views:views]];
}

- (void)addTextInput
{
	UIView *textInput = self.textInputControl;
	if (!textInput) {
		return;
	}

	textInput.translatesAutoresizingMaskIntoConstraints = NO;
	[self.textInputContainer addSubview:textInput];

	NSDictionary *views = @{@"view" : textInput};
	[self.textInputContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
	                                                                                options:0
	                                                                                metrics:nil
	                                                                                  views:views]];
	[self.textInputContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
	                                                                                options:0
	                                                                                metrics:nil
	                                                                                  views:views]];
}

- (void)style
{
	self.textField.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeMedium];
	self.titleLabel.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXSmall];
	self.titleLabel.textColor = MLStyleSheetManager.styleSheet.greyColor;
	self.accessoryLabel.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXSmall];
	self.placeholderLabel.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeMedium];
	self.placeholderLabel.textColor = MLStyleSheetManager.styleSheet.greyColor;
	[self stateDependantStyle];
}

- (void)stateDependantStyle
{
	UIColor *textColor = MLStyleSheetManager.styleSheet.blackColor;
	UIColor *lineColor = MLStyleSheetManager.styleSheet.midGreyColor;
	UIColor *labelColor = MLStyleSheetManager.styleSheet.greyColor;
	UIColor *accessoryLabelColor = MLStyleSheetManager.styleSheet.darkGreyColor;
	CGFloat lineHeight = kMLTextFieldThinLine;

	switch (self.state) {
		case MLTitledTextFieldStateDisabled: {
			textColor = MLStyleSheetManager.styleSheet.midGreyColor;
			labelColor = MLStyleSheetManager.styleSheet.midGreyColor;
			break;
		}

		case MLTitledTextFieldStateEditing: {
			lineColor = MLStyleSheetManager.styleSheet.secondaryColor;
			lineHeight = kMLTextFieldThickLine;
			break;
		}

		case MLTitledTextFieldStateError: {
			lineColor = accessoryLabelColor = MLStyleSheetManager.styleSheet.errorColor;
			lineHeight = kMLTextFieldThickLine;
			break;
		}

		default: {
			lineColor = MLStyleSheetManager.styleSheet.midGreyColor;
			break;
		}
	}

	__weak typeof(self)weakSelf = self;

	[UIView animateWithDuration:.25f animations: ^{
	    weakSelf.placeholderLabel.alpha = weakSelf.text.length ? 0 : 1;
	}];

	[UIView animateWithDuration:.5f animations: ^{
	    weakSelf.textField.textColor = textColor;
	    weakSelf.titleLabel.textColor = labelColor;
	    weakSelf.lineView.backgroundColor = lineColor;
	    weakSelf.textField.tintColor = lineColor;
	    weakSelf.lineViewHeight.constant = lineHeight;
	    weakSelf.accessoryLabel.textColor = accessoryLabelColor;
	}];
}

- (void)setupInnerTextWithAlignment:(NSTextAlignment)textAlignment
{
	self.placeholderLabel.textAlignment = textAlignment;
	self.titleLabel.textAlignment = textAlignment;
	self.textField.textAlignment = textAlignment;
	self.accessoryLabel.textAlignment = textAlignment;
}

- (void)updateCharacterCount
{
	if (!self.charactersCountVisible) {
		return;
	}

	NSString *countString;
	if (self.maxCharacters) {
		NSString *format = [MLTitledSingleLineStringProvider localizedString:@"CHARACTER_COUNT_FORMAT"];
		countString = [NSString stringWithFormat:format, (unsigned long)self.text.length, (unsigned long)self.maxCharacters];
	} else {
		countString = [NSString stringWithFormat:@"%lu", (unsigned long)self.text.length];
	}

	self.helperDescription = countString;
}

- (void)observeText
{
	[self addObserver:self
	       forKeyPath:NSStringFromSelector(@selector(text))
	          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
	          context:nil];
}

#pragma mark Custom Setters

- (void)setText:(NSString *)text
{
	if (![self validateLength:text]) {
		return;
	}
	self.textCache = text;
	self.textField.text = text;
	[self style];
}

- (void)setTitle:(NSString *)title
{
	_title = title.copy;
	self.titleLabel.text = title;
}

- (void)setHelperDescription:(NSString *)helperDescription
{
	if (self.errorDescription) {
		return;
	}

	_helperDescription = helperDescription;
	self.accessoryLabel.text = _helperDescription;
}

- (void)setErrorDescription:(NSString *)errorDescription
{
	if (errorDescription == _errorDescription
	    || [errorDescription isEqualToString:_errorDescription]) {
		return;
	}

	_errorDescription = errorDescription.copy;
	__weak typeof(self)weakSelf = self;

	if (!_errorDescription && self.helperDescription.length) {
		[self updateCharacterCount];
		self.accessoryLabel.text = self.helperDescription;
		return;
	}

	[UIView animateWithDuration:0.3 animations: ^{
	    weakSelf.accessoryLabel.text = errorDescription;
	    [weakSelf.accessoryLabel invalidateIntrinsicContentSize];
	    [weakSelf setNeedsLayout];
	    [weakSelf layoutIfNeeded];
	}];
	[self style];
}

- (void)setPlaceholder:(NSString *)placeholder
{
	self.placeholderLabel.text = placeholder;
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	self.textField.userInteractionEnabled = enabled;
	[self style];
}

- (void)setMaxCharacters:(NSUInteger)maxCharacters
{
	_maxCharacters = maxCharacters;
	[self updateCharacterCount];
}

- (void)setCharactersCountVisible:(BOOL)charactersCountVisible
{
	_charactersCountVisible = charactersCountVisible;
	[self updateCharacterCount];
}

- (void)setAccessoryView:(UIView *)accessoryView
{
	[self.accessoryView removeFromSuperview];
	[accessoryView removeFromSuperview];

	UIView *container = self.accessoryViewContainer;
	_accessoryView = accessoryView;

	if (!accessoryView) {
		return;
	}

	accessoryView.translatesAutoresizingMaskIntoConstraints = NO;

	UILayoutConstraintAxis axis = UILayoutConstraintAxisHorizontal;
	CGFloat contentHugging = [container contentHuggingPriorityForAxis:axis];
	[accessoryView setContentHuggingPriority:contentHugging forAxis:axis];
	CGFloat compressionResistance = [container contentCompressionResistancePriorityForAxis:axis];
	[accessoryView setContentCompressionResistancePriority:compressionResistance forAxis:axis];
	[container addSubview:accessoryView];

	NSDictionary *views = @{@"view" : accessoryView};
	[container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
	                                                                  options:0
	                                                                  metrics:nil
	                                                                    views:views]];
	[container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
	                                                                  options:0
	                                                                  metrics:nil
	                                                                    views:views]];
	[self setNeedsLayout];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
	self.textField.keyboardType = keyboardType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
	self.textField.autocapitalizationType = autocapitalizationType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
	self.textField.autocorrectionType = autocorrectionType;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
	_secureTextEntry = secureTextEntry;

	self.textField.secureTextEntry = secureTextEntry;
}

#pragma mark Custom getters

- (NSString *)text
{
	return self.textCache ? : @"";
}

- (UIView <UITextInputTraits, UITextInput> *)textInputControl
{
	if (!self.textField) {
		self.textField = [[UITextField alloc] init];
		self.textField.delegate = self;
		[self.textField addTarget:self
		                   action:@selector(textFieldDidChange:)
		         forControlEvents:UIControlEventEditingChanged];
	}
	return self.textField;
}

- (NSString *)placeholder
{
	return self.placeholderLabel.text;
}

- (UIKeyboardType)keyboardType
{
	return self.textField.keyboardType;
}

- (UITextAutocapitalizationType)autocapitalizationType
{
	return self.textField.autocapitalizationType;
}

- (UITextAutocorrectionType)autocorrectionType
{
	return self.textField.autocorrectionType;
}

#pragma mark State handling

- (MLTitledTextFieldState)state
{
	if (!self.isEnabled) {
		return MLTitledTextFieldStateDisabled;
	}
	if (self.errorDescription.length) {
		return MLTitledTextFieldStateError;
	}
	if (self.isFirstResponder) {
		return MLTitledTextFieldStateEditing;
	}
	return MLTitledTextFieldStateNormal;
}

#pragma mark TextViewDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
	self.textCache = textField.text;
	[self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidBeginEditing:(UITextField *)textView
{
	[self style];
	if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		[self.delegate textFieldDidBeginEditing:self];
	}
	[self sendActionsForControlEvents:UIControlEventEditingDidBegin];
}

- (void)textFieldDidEndEditing:(UITextField *)textView
{
	[self style];
	if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
		[self.delegate textFieldDidEndEditing:self];
	}
	[self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL shouldChange = YES;
	NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (![self validateLength:finalString]) {
		shouldChange = NO;
	}

	if (shouldChange && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
		shouldChange = [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:string];
	}

	if (shouldChange) {
		self.textCache = finalString;
	}

	return shouldChange;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
		return [self.delegate textFieldShouldBeginEditing:self];
	}
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
		return [self.delegate textFieldShouldEndEditing:self];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
		return [self.delegate textFieldShouldReturn:self];
	}
	return YES;
}

#pragma mark UIResponder

- (BOOL)isFirstResponder
{
	return self.textField.isFirstResponder;
}

- (BOOL)becomeFirstResponder
{
	return self.textField.becomeFirstResponder;
}

- (BOOL)canBecomeFirstResponder
{
	return self.textField.canBecomeFirstResponder;
}

- (BOOL)resignFirstResponder
{
	return self.textField.resignFirstResponder;
}

- (BOOL)canResignFirstResponder
{
	return self.textField.canResignFirstResponder;
}

#pragma mark Validations

- (BOOL)validateLength:(NSString *)string
{
	return !(self.maxCharacters && string.length > self.maxCharacters);
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSString *, id> *)change context:(void *)context
{
	if ([keyPath isEqualToString:NSStringFromSelector(@selector(text))]) {
		[self updateCharacterCount];
		self.errorDescription = nil;
		[self style];
	}
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:NSStringFromSelector(@selector(text))];
}

+ (NSSet *)keyPathsForValuesAffectingText
{
	return [NSSet setWithObject:@"textCache"];
}

@end
