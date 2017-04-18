//
// MPSDKLoadingView.m
// MercadoPago
//
// Created by Matias Casanova on 02/10/14.
// Copyright (c) 2014 MercadoPago. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]

#import "MPSDKLoadingView.h"
#import "MLSpinner.h"

@interface MPSDKLoadingView ()

@property (nonatomic, strong) MLSpinner *spinner;

@end

@implementation MPSDKLoadingView

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame backgroundColor:[UIColor whiteColor] loadingText:nil loadingColor:nil];
}

- (id)initWithBackgroundColor:(UIColor *)color
{
    return [self initWithBackgroundColor:color loadingText:nil];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color
{
    return [self initWithFrame:frame backgroundColor:color loadingText:nil loadingColor:nil];
}
- (id)initWithLoadingColor:(UIColor *)loadingColor
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    return [self initWithFrame:frame backgroundColor:nil loadingText:nil loadingColor:loadingColor];
}

- (id)initWithBackgroundColor:(UIColor *)color loadingText:(NSString *)text
{
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	return [self initWithFrame:frame backgroundColor:color loadingText:text loadingColor:nil];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color loadingText:(NSString *)text loadingColor:(UIColor *)loadingColor
{
	self = [super initWithFrame:frame];

	if (self) {
		self.tintColor = [UIColor blackColor];
		self.backgroundColor = color ? color : UIColorFromRGB(0xFFFFFF);
		self.accessibilityLabel = @"Loading";
		self.opaque = YES;
		self.alpha = 1;
		self.tag = kLoadingViewTag;


        MLSpinnerConfig *config = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeBig primaryColor:loadingColor? loadingColor : UIColorFromRGB(0x009EE3) secondaryColor:loadingColor? loadingColor : UIColorFromRGB(0x009EE3)];


		self.spinner = [[MLSpinner alloc] initWithConfig:config text:text];

		[self addSubview:self.spinner];
		[self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];

		// center spinner vertically in view
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
		                                                 attribute:NSLayoutAttributeCenterY
		                                                 relatedBy:NSLayoutRelationEqual
		                                                    toItem:self
		                                                 attribute:NSLayoutAttributeCenterY
		                                                multiplier:1.0
		                                                  constant:0.0]];

		// set spinner alligned with label
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
		                                                 attribute:NSLayoutAttributeCenterX
		                                                 relatedBy:NSLayoutRelationEqual
		                                                    toItem:self
		                                                 attribute:NSLayoutAttributeCenterX
		                                                multiplier:1.0f
		                                                  constant:0]];

		[self rotateSpinner];

		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(rotateSpinner)
		                                             name:UIApplicationWillEnterForegroundNotification
		                                           object:nil];
	}

	return self;
}

- (void)didMoveToSuperview
{
	[self rotateSpinner];
}

- (void)didMoveToWindow
{
	[self rotateSpinner];
}

- (void)rotateSpinner
{
	[self.spinner showSpinner];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
