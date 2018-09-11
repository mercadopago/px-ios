//
// MLButton.m
// MLUI
//
// Created by Julieta Puente on 13/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLButton.h"
#import "MLButtonConfigStyle.h"
#import "UIColor+MLColorPalette.h"
#import "UIFont+MLFonts.h"
#import "MLButtonConfig.h"
#import "MLSpinner.h"
#import "MLButtonStylesFactory.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kMLButtonHorizontalPadding = 15.0f;
static const CGFloat kMLButtonVerticalPadding = 15.0f;
static const CGFloat kMLButtonCornerRadius = 4.0f;
static const CGFloat kMLButtonBorderWidth = 1.0f;
static const CGFloat kMLButtonLineSpacing = 7.0f;

@interface MLButton ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CALayer *backgroundLayer;
@property (nonatomic, strong) MLSpinner *spinner;
@property (nonatomic, strong) MLSpinnerConfig *spinnerConfig;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation MLButton

+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

#pragma mark inits

- (instancetype)init
{
	self = [self initWithConfig:[MLButtonStylesFactory configForButtonType:MLButtonTypePrimaryAction]];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
		self.style = MLButtonStylePrimaryAction;
	}
	return self;
}

- (instancetype)initWithStyle:(MLButtonStyle)style
{
	self = [super initWithFrame:CGRectZero];
	if (self) {
		[self setup];
		self.style = style;
	}
	return self;
}

- (instancetype)initWithConfig:(MLButtonConfig *)config
{
	if (self = [super initWithFrame:CGRectZero]) {
		_config = config;
		[self setup];
		[self updateLookAndFeel];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.backgroundLayer.frame = self.bounds;
}

#pragma mark configuration methods

- (void)setup
{
	self.translatesAutoresizingMaskIntoConstraints = NO;

	self.backgroundColor = [UIColor clearColor];

	self.backgroundLayer = [CALayer layer];
	[self.layer addSublayer:self.backgroundLayer];

	self.backgroundLayer.borderWidth = kMLButtonBorderWidth;

	self.label = [[UILabel alloc] initWithFrame:CGRectZero];
	self.label.translatesAutoresizingMaskIntoConstraints = NO;
	self.label.numberOfLines = 0;

	[self addSubview:self.label];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-p-[label]-p-|" options:0 metrics:@{@"p" : @(kMLButtonHorizontalPadding)} views:@{@"label" : self.label}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-p@priority-[label]-p@priority-|" options:0 metrics:@{@"p" : @(kMLButtonVerticalPadding), @"priority" : @999} views:@{@"label" : self.label}]];
}

- (void)setupStatesConfig
{
    switch (self.style) {
		case MLButtonStylePrimaryAction: {
			self.config = [MLButtonStylesFactory configForButtonType:MLButtonTypePrimaryAction];
			break;
		}

		case MLButtonStyleSecondaryAction: {
			self.config = [MLButtonStylesFactory configForButtonType:MLButtonTypeSecondaryAction];
			break;
		}

		case MLButtonStylePrimaryOption: {
			self.config = [MLButtonStylesFactory configForButtonType:MLButtonTypePrimaryOption];
			break;
		}

		case MLButtonStyleSecondaryOption: {
			self.config = [MLButtonStylesFactory configForButtonType:MLButtonTypeSecondaryOption];
			break;
		}
	}

    [self updateLookAndFeel];
}

- (void)updateLookAndFeel
{
    self.label.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeMedium];
    self.label.textColor = self.isEnabled ? (self.isHighlighted ? self.config.highlightedState.contentColor : self.config.defaultState.contentColor) : self.config.disableState.contentColor;
    self.backgroundLayer.backgroundColor = self.isEnabled ? (self.isHighlighted ? self.config.highlightedState.backgroundColor.CGColor : self.config.defaultState.backgroundColor.CGColor) : self.config.disableState.backgroundColor.CGColor;
    self.backgroundLayer.borderColor = self.isEnabled ? (self.isHighlighted ? self.config.highlightedState.borderColor.CGColor : self.config.defaultState.borderColor.CGColor) : self.config.disableState.borderColor.CGColor;
    self.backgroundLayer.cornerRadius = kMLButtonCornerRadius;
}

- (void)updateStatesConfig:(MLButtonConfig *)buttonStates
{
    self.config = buttonStates;
}

- (void)setupLoadingStyle
{
    self.label.hidden = YES;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.spinner];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    self.backgroundLayer.backgroundColor = self.config.loadingState.backgroundColor.CGColor;
    self.backgroundLayer.borderColor = self.config.loadingState.borderColor.CGColor;

    [self.spinner showSpinner];
}

- (void)showLoadingStyle
{
    if (self.config.loadingState) {
        self.enabled = NO;
        self.isLoading = YES;
        [self setupLoadingStyle];
	}
}

- (void)hideLoadingStyle
{
    self.enabled = YES;
    self.label.hidden = NO;
    self.isLoading = NO;
    [self.spinner hideSpinner];
    [self updateLookAndFeel];
}

#pragma mark setters and getters

- (void)setStyle:(MLButtonStyle)style
{
    _style = style;
    [self setupStatesConfig];
}

- (void)setEnabled:(BOOL)enabled
{
    if (!self.isLoading) {
        [super setEnabled:enabled];
        [self updateLookAndFeel];
	}
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateLookAndFeel];
}

- (NSString *)buttonTitle
{
    return [self.label.attributedText string];
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = kMLButtonLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSString *title = buttonTitle ? : @"";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title.length)];

    self.label.attributedText = attributedString;
}

- (void)setConfig:(MLButtonConfig *)config
{
    _config = config;
    [self updateLookAndFeel];
}

#pragma mark lazy initializations

- (MLSpinner *)spinner
{
    if (!_spinner) {
        _spinner = [[MLSpinner alloc] initWithConfig:self.spinnerConfig text:nil];
	}
    return _spinner;
}

- (MLSpinnerConfig *)spinnerConfig
{
    if (!_spinnerConfig) {
        _spinnerConfig = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeSmall primaryColor:[UIColor whiteColor] secondaryColor:[UIColor whiteColor]];
	}
    return _spinnerConfig;
}

@end
