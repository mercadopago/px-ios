//
// MLActionButton.m
// MercadoLibre
//
// Created by Matias Ginart on 18/09/12.
// Copyright (c) 2012 Casa. All rights reserved.
//

#import "MLUIActionButton.h"

static const NSInteger kDefaultFontSize = 16;
static const NSInteger kDefaultHeigth = 44;
static const CGFloat kDefaultCornerRadius = 4.0f;
static const CGFloat kDefaultBorderWidth = 0.f;

@interface MLUIActionButton ()
@property (nonatomic) BOOL mustChangeBackgroundColor;
@end

@implementation MLUIActionButton

- (id)initWithFixHeigthConstraintAndStyle:(MLUIActionButtonStyle)style
{
	self = [self init];
	if (self) {
		[self setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self setupForStyle:style];
		self.isAccessibilityElement = YES;
		[self setDefaultHeightContraint];
	}

	return self;
}

- (id)initWithStyle:(MLUIActionButtonStyle)style
{
	self = [self initWithFrame:CGRectMake(0, 0, 0, 0)];
	if (self) {
		[self setupForStyle:style];
		self.isAccessibilityElement = YES;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [self initWithFrame:frame andStyle:MLUIActionButtonStylePrimary];
	if (self) {
		self.isAccessibilityElement = YES;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame andStyle:(MLUIActionButtonStyle)buttonStyle
{
	if (self = [super initWithFrame:frame]) {
		[self setupForStyle:buttonStyle];
		self.isAccessibilityElement = YES;
	}

	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setDefaultHeightContraint];
}

- (void)setDefaultHeightContraint
{
	if (self.heightConstraint) {
		self.heightConstraint.constant = kDefaultHeigth;
	} else {
		self.heightConstraint = [NSLayoutConstraint
		                         constraintWithItem:self
		                                  attribute:NSLayoutAttributeHeight
		                                  relatedBy:NSLayoutRelationEqual
		                                     toItem:nil
		                                  attribute:NSLayoutAttributeHeight
		                                 multiplier:1
		                                   constant:kDefaultHeigth];
		[self addConstraint:self.heightConstraint];
	}
}

- (void)activeSimulatedDisabled
{
	[self setupForStyle:MLUIActionButtonStyleDisabled];
}

- (void)setupForStyle:(MLUIActionButtonStyle)buttonStyle
{
	UIColor *backgroundColor = nil;
	UIColor *highlightedColor = nil;
	UIColor *fontColor = nil;
	UIColor *highlightedTextColor = nil;
	NSInteger fontSize = kDefaultFontSize;

	self.layer.cornerRadius = kDefaultCornerRadius;
	self.layer.borderWidth = kDefaultBorderWidth;
	self.layer.borderColor = [UIColor colorWithWhite:.8f alpha:1.f].CGColor;

	switch (buttonStyle) {
		case MLUIActionButtonStylePrimary:
		default: {
			backgroundColor = [UIColor colorWithRed:0.125 green:0.137 blue:0.376 alpha:1];

			highlightedColor = [UIColor colorWithRed:0.094 green:0.106 blue:0.243 alpha:1];

			fontColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

			break;
		}

		case MLUIActionButtonStyleDisabled: {
			backgroundColor = [UIColor colorWithRed:0.824 green:0.824 blue:0.824 alpha:1];

			highlightedColor = nil;

			fontColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];

			break;
		}

		case MLUIActionButtonStyleSecondary: {
			backgroundColor = [UIColor colorWithRed:0.702 green:0.804 blue:0.976 alpha:1];

			highlightedColor = [UIColor colorWithRed:0.706 green:0.78 blue:0.851 alpha:1];

			fontColor = [UIColor colorWithRed:0.318 green:0.427 blue:0.506 alpha:1];
			break;
		}

		case MLUIActionButtonStyleTertiary: {
			self.layer.borderWidth = 1;
			backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

			highlightedColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];

			fontColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
			break;
		}

		case MLUIActionButtonStyleOnlyText: {
			backgroundColor = [UIColor clearColor];
			highlightedColor = [UIColor clearColor];
			fontColor = [UIColor colorWithRed:71.f / 255.f green:117.f / 255.f blue:231.f / 255.f alpha:1];
			highlightedTextColor = [UIColor colorWithRed:37.f / 255.f green:59.f / 255.f blue:140.f / 255.f alpha:1];
			fontSize = 13;
			break;
		}
	}

	_buttonStyle = buttonStyle;
	self.baseColor = backgroundColor;
	[self setBackgroundColor:self.baseColor];

	if (highlightedColor) {
		self.highlightedColor = highlightedColor;
		self.mustChangeBackgroundColor = YES;
	} else {
		self.mustChangeBackgroundColor = NO;
	}

	[self setupTitleStyle:fontColor highlightedColor:highlightedTextColor fontSize:fontSize];
}

- (void)setButtonStyle:(MLUIActionButtonStyle)buttonStyle
{
	[self setupForStyle:buttonStyle];
}

- (void)setupTitleStyle:(UIColor *)fontColor highlightedColor:(UIColor *)highlightedColor fontSize:(NSInteger)fontSize
{
	self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
	[self setTitleColor:fontColor forState:UIControlStateNormal];

	if (highlightedColor) {
		[self setTitleColor:highlightedColor forState:UIControlStateHighlighted];
	} else {
		[self setTitleColor:fontColor forState:UIControlStateHighlighted];
	}
}

- (void)setHighlighted:(BOOL)highlighted
{
	if (highlighted != self.highlighted && self.mustChangeBackgroundColor) {
		if (highlighted) {
			self.backgroundColor = self.highlightedColor;
		} else {
			self.backgroundColor = self.baseColor;
		}
	}
	[super setHighlighted:highlighted];
}

@end
