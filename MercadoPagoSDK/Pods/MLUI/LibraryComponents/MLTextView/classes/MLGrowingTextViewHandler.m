//
// MLGrowingTextViewHandler.m
// MLGrowingTextViewHandler-objc
//
// Created by hsusmita on 13/03/15.
// Copyright (c) 2015 hsusmita.com. All rights reserved.
//

#import "MLGrowingTextViewHandler.h"

static CGFloat kDefaultAnimationDuration = 0.5;
static NSInteger kMinimumNumberOfLines = 1;
static NSInteger kMaximumNumberOfLines = INT_MAX;

@interface MLGrowingTextViewHandler ()

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) CGFloat initialHeight;
@property (nonatomic, assign) CGFloat maximumHeight;
@property (nonatomic, assign) NSInteger maximumNumberOfLines;
@property (nonatomic, assign) NSInteger minimumNumberOfLines;

@end

@implementation MLGrowingTextViewHandler

- (id)initWithTextView:(UITextView *)textView heightConstraint:(NSLayoutConstraint *)heightConstraint
{
	if (self = [super init]) {
		self.textView = textView;
		self.heightConstraint = heightConstraint;
		self.animationDuration = kDefaultAnimationDuration;
		[self updateMinimumNumberOfLines:kMinimumNumberOfLines andMaximumNumberOfLine:kMaximumNumberOfLines];
	}
	return self;
}

#pragma mark - Public Methods

- (void)updateMinimumNumberOfLines:(NSInteger)minimumNumberOfLines andMaximumNumberOfLine:(NSInteger)maximumNumberOfLines
{
	_minimumNumberOfLines = minimumNumberOfLines;
	_maximumNumberOfLines = maximumNumberOfLines;
	[self updateInitialHeightAndResize];
}

- (void)resizeTextViewAnimated:(BOOL)animated
{
	NSInteger textViewNumberOfLines = self.currentNumberOfLines;
	CGFloat verticalAlignmentConstant = 0.0;
	if (textViewNumberOfLines <= self.minimumNumberOfLines) {
		verticalAlignmentConstant = self.initialHeight;
	} else if ((textViewNumberOfLines > self.minimumNumberOfLines) && (textViewNumberOfLines <= self.maximumNumberOfLines)) {
		CGFloat currentHeight = [self currentHeight];
		verticalAlignmentConstant = (currentHeight > self.initialHeight) ? currentHeight : self.initialHeight;
	} else if (textViewNumberOfLines > self.maximumNumberOfLines) {
		verticalAlignmentConstant = self.maximumHeight;
	}
	if (self.heightConstraint.constant != verticalAlignmentConstant) {
		[self updateVerticalAlignmentWithHeight:verticalAlignmentConstant animated:animated];
	}
	if (textViewNumberOfLines <= self.maximumNumberOfLines) {
		[self.textView setContentOffset:CGPointZero animated:YES];
	}
}

#pragma mark - Private Helpers

- (void)updateInitialHeightAndResize
{
	[self.textView layoutIfNeeded];
	self.initialHeight = [self estimatedInitialHeight];
	self.maximumHeight = [self estimatedMaximumHeight];
	[self resizeTextViewAnimated:NO];
}

- (CGFloat)estimatedInitialHeight
{
	CGFloat totalHeight = [self caretHeight] * self.minimumNumberOfLines + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom;
	return fmax(totalHeight, self.textView.frame.size.height);
}

- (CGFloat)estimatedMaximumHeight
{
	CGFloat totalHeight = [self caretHeight] * self.maximumNumberOfLines + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom;
	return totalHeight;
}

- (CGFloat)caretHeight
{
	return [self.textView caretRectForPosition:self.textView.selectedTextRange.end].size.height;
}

- (CGFloat)currentHeight
{
	CGFloat width = self.textView.bounds.size.width - 2.0 * self.textView.textContainer.lineFragmentPadding;
	CGRect boundingRect = [self.textView.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
	                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
	                                                    attributes:@{NSFontAttributeName : self.textView.font}
	                                                       context:nil];
	CGFloat heightByBoundingRect = CGRectGetHeight(boundingRect) + self.textView.font.lineHeight;
	return MAX(heightByBoundingRect, self.textView.contentSize.height);
}

- (NSInteger)currentNumberOfLines
{
	CGFloat caretHeight = [self.textView caretRectForPosition:self.textView.selectedTextRange.end].size.height;
	CGFloat totalHeight = [self currentHeight] + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom;
	NSInteger numberOfLines = (totalHeight / caretHeight) - 1;
	return numberOfLines;
}

- (void)updateVerticalAlignmentWithHeight:(CGFloat)height animated:(BOOL)animated
{
	self.heightConstraint.constant = height;
	if (animated) {
		[UIView animateWithDuration:self.animationDuration
		                 animations: ^{
		    [self.textView.superview layoutIfNeeded];
		}
		                 completion:nil];
	} else {
		[self.textView.superview layoutIfNeeded];
	}
}

- (void)setText:(NSString *)text animated:(BOOL)animated
{
	self.textView.text = text;
	if (text.length > 0) {
		[self resizeTextViewAnimated:animated];
	} else {
		[self updateVerticalAlignmentWithHeight:self.initialHeight animated:animated];
	}
}

@end
