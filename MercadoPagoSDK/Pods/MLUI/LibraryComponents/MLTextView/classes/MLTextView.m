//
// MLTextView.m
// MLUI
//
// Created by MAURO CARREÑO on 5/17/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import "MLTextView.h"
#import "UIFont+MLFonts.h"
#import "MLGrowingTextViewHandler.h"
#import "MLUIBundle.h"

static NSInteger kHighestPriority = 999;
static NSInteger kLowestPriority = 1;

@implementation MLTextViewPlaceholder

- (void)showPlaceholder:(BOOL)doShow
{
	CGFloat finalAlpha = doShow ? 1.f : 0.f;

	// If the previous state was the same as the first, do nothing
	if (finalAlpha == self.alpha) {
		return;
	}
	__weak __typeof__(self)weakSelf = self;

	[UIView animateWithDuration:.25f animations: ^{
	    weakSelf.alpha = finalAlpha;
	}];
}

- (void)showPlaceholderForText:(NSString *)text
{
	[self showPlaceholder:(text == nil || text.length == 0)];
}

@end

#pragma MLTextView class

@interface MLTextView ()

@property (nonatomic, weak, readwrite) IBOutlet UITextView *_Nullable textView;
@property (nonatomic, weak, readwrite) IBOutlet MLTextViewPlaceholder *_Nullable textViewPlaceholder;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *_Nullable textViewHeightConstraint;
@property (strong, nonatomic) MLGrowingTextViewHandler *_Nullable handler;

@end

@implementation MLTextView

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
	self.minLines = 1;
	self.maxLines = 1;
	self.placeholder = @"";
	self.text = @"";
	self.flexibleSize = true;

	[self loadFromNib];
	[self setupHandler];

	[self.textView setFont:[UIFont systemFontOfSize:16]];
	[self.textViewPlaceholder setFont:[UIFont systemFontOfSize:16]];
}

- (void)loadFromNib
{
	NSString *nibName = @"MLTextView";
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

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	if (newWindow == nil) {
		// Will be removed from window, similar to -viewDidUnload.
		// Unsubscribe from UITextViewTextDidChangeNotification notifications here.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
	}
}

- (void)didMoveToWindow
{
	if (self.window) {
		// Added to a window, similar to -viewDidLoad.
		// Subscribe to UITextViewTextDidChangeNotification here.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
	}
}

- (void)styleHasChanged
{
	[self.textViewPlaceholder showPlaceholderForText:self.textView.text];

	if (!self.flexibleSize) {
		self.handler = nil;
		return;
	}

	[self.handler updateMinimumNumberOfLines:_minLines andMaximumNumberOfLine:_maxLines];
	[self.handler setText:self.textView.text animated:false];
}

- (void)setupHandler
{
	self.handler = [[MLGrowingTextViewHandler alloc]initWithTextView:self.textView heightConstraint:self.textViewHeightConstraint];
	[self styleHasChanged];
}

- (void)textViewDidChange:(NSNotification *)textViewNotification
{
	if (textViewNotification.object != self.textView) {
		return;
	}

	[self.textViewPlaceholder showPlaceholderForText:self.textView.text];
	[self.handler setText:self.textView.text animated:false];
}

#pragma mark Custom Setters

- (void)setFlexibleSize:(BOOL)flexibleSize
{
	_flexibleSize = flexibleSize;
	// Changing the priority is made to avoid conflicts. A required constraint (1000) cant be changed that's why 999 (kHighestPriority) is used.
	_textViewHeightConstraint.priority = _flexibleSize ? kHighestPriority : kLowestPriority;
	[self styleHasChanged];
}

- (void)setText:(NSString *)text
{
	self.textView.text = text;
	[self.textViewPlaceholder showPlaceholderForText:self.textView.text];
	if (self.flexibleSize) {
		[self.handler setText:text animated:false];
		[self.superview layoutIfNeeded];
	}
}

- (void)setPlaceholder:(NSString *)title
{
	self.textViewPlaceholder.text = title;
	[self.textViewPlaceholder showPlaceholderForText:self.textView.text];
}

- (void)setMinLines:(NSUInteger)lines
{
	_minLines = lines == 0 ? 1 : lines;
	_maxLines = _maxLines < _minLines ? _minLines : _maxLines;

	[self.handler updateMinimumNumberOfLines:_minLines andMaximumNumberOfLine:_maxLines];
}

- (void)setMaxLines:(NSUInteger)lines
{
	_maxLines = lines < _minLines ? _minLines : lines;

	[self.handler updateMinimumNumberOfLines:_minLines andMaximumNumberOfLine:_maxLines];
}

#pragma mark Custom getters

- (NSString *)text
{
	return self.textView.text;
}

- (NSString *)placeholder
{
	return self.textViewPlaceholder.text;
}

@end
