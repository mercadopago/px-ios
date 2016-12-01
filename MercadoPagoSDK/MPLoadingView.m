//
// MPLoadingView.m
// MercadoPago
//
// Created by Matias Casanova on 02/10/14.
// Copyright (c) 2014 MercadoPago. All rights reserved.
//

#import "MPLoadingView.h"
#import "UIView+RotateView.h"
#import <MercadoPagoSDK/MercadoPagoSDK-Swift.h>

@interface MPLoadingView ()



@end

@implementation MPLoadingView



#define LABEL_WIDTH 90
#define LABEL_HEIGHT 20

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame backgroundColor:[UIColor whiteColor] loadingText:nil];
}

- (id)initWithBackgroundColor:(UIColor *)color
{
	return [self initWithBackgroundColor:color loadingText:nil];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color
{
	return [self initWithFrame:frame backgroundColor:color loadingText:nil];
}

- (id)initWithBackgroundColor:(UIColor *)color loadingText:(NSString *)text
{
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	return [self initWithFrame:frame backgroundColor:color loadingText:text];
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color loadingText:(NSString *)text
{
	self = [super initWithFrame:frame];

	if (self) {
		self.tintColor = [UIColor blackColor];
        self.backgroundColor = color; //? color : [UIColor backgroundColor];
		self.accessibilityLabel = @"Loading";
		self.opaque = YES;
		self.alpha = 1;
		self.tag = kLoadingViewTag;

		UILabel *label = [UILabel new];
		NSMutableAttributedString *attributedString;

		if (text != nil) {
			attributedString = [[NSMutableAttributedString alloc] initWithString:text];
		} else {
			NSString *defaultText = NSLocalizedStringFromTableInBundle(@"Cargando...", @"MPUILocalizable", [NSBundle mainBundle], nil);
			attributedString = [[NSMutableAttributedString alloc] initWithString:defaultText];
		}

		UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:13.0];
		NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
		style.alignment = NSTextAlignmentCenter;
		[attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedString.length)];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, attributedString.length)];
		label.attributedText = attributedString;

		[self addSubview:label];
		[label setTranslatesAutoresizingMaskIntoConstraints:NO];

		// center label horizontally in view
		[self addConstraint:[NSLayoutConstraint constraintWithItem:label
		                                                 attribute:NSLayoutAttributeCenterX
		                                                 relatedBy:NSLayoutRelationEqual
		                                                    toItem:self
		                                                 attribute:NSLayoutAttributeCenterX
		                                                multiplier:1.0
		                                                  constant:10]];

		// center label vertically in view
		[self addConstraint:[NSLayoutConstraint constraintWithItem:label
		                                                 attribute:NSLayoutAttributeCenterY
		                                                 relatedBy:NSLayoutRelationEqual
		                                                    toItem:self
		                                                 attribute:NSLayoutAttributeCenterY
		                                                multiplier:1.0
		                                                  constant:0.0]];

        
        
        UIImage *image = [MercadoPago getImage:@"mpui-loading_default"];
		self.spinner = [[UIImageView alloc] initWithImage:image];
        
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
		[self addConstraint:[NSLayoutConstraint constraintWithItem:label
		                                                 attribute:NSLayoutAttributeLeading
		                                                 relatedBy:NSLayoutRelationEqual
		                                                    toItem:self.spinner
		                                                 attribute:NSLayoutAttributeTrailing
		                                                multiplier:1.0f
		                                                  constant:10]];

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
	[self.spinner rotateViewWithDuration:15];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end
