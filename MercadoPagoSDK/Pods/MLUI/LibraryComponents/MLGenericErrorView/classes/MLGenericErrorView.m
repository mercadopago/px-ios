//
// MLGenericErrorView.m
// MLUI
//
// Created by Josefina Bustamante on 14/11/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLGenericErrorView.h"
#import <MLUI/UILabel+MLStyle.h>
#import <MLUI/UIColor+MLColorPalette.h>
#import <MLUI/MLButton.h>
#import <MLUI/MLButtonStylesFactory.h>
#import "MLUIBundle.h"

static CGFloat const kMLUIScreenHeight = 667;

@interface MLGenericErrorView ()

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet MLButton *retryButton;
@property (nonatomic, strong) MLVoidBlock actionBlock;

@end

@implementation MLGenericErrorView

- (instancetype)init
{
	NSString *nibName = NSStringFromClass([self class]);
	self = [[MLUIBundle mluiBundle] loadNibNamed:nibName
	                                       owner:nil
	                                     options:nil].firstObject;
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self setLabelsStyle];
	[self setLabelsTextColor];
	self.retryButton.config = [MLButtonStylesFactory configForButtonType:MLButtonTypePrimaryOption];
	[self setRetryButtonVisible:YES];
}

- (void)setLabelsStyle
{
	if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if ([[UIScreen mainScreen] bounds].size.height >= kMLUIScreenHeight) {
			[self.title ml_setStyle:MLStyleLightLarge];
			[self.subtitle ml_setStyle:MLStyleLightMedium];
		} else {
			[self.title ml_setStyle:MLStyleLightMedium];
			[self.subtitle ml_setStyle:MLStyleLightSmall];
		}
	} else {
		[self.title ml_setStyle:MLStyleLightLarge];
		[self.subtitle ml_setStyle:MLStyleLightMedium];
	}
}

- (void)setLabelsTextColor
{
	self.title.textColor = [UIColor ml_meli_black];
	self.subtitle.textColor = [UIColor ml_meli_dark_grey];
}

+ (MLGenericErrorView *)genericErrorViewWithImage:(UIImage *)image
                                            title:(NSString *)title
                                         subtitle:(NSString *)subtitle
                                      buttonTitle:(NSString *)buttonTitle
                                      actionBlock:(MLVoidBlock)actionBlock
{
	MLGenericErrorView *errorView = [[MLGenericErrorView alloc] init];
	errorView.title.text = title;
	errorView.subtitle.text = subtitle;
	errorView.imageView.image = image;
	errorView.retryButton.buttonTitle = buttonTitle;
	if (actionBlock) {
		errorView.actionBlock = actionBlock;
	} else {
		[errorView setRetryButtonVisible:NO];
	}
	return errorView;
}

- (IBAction)retryButtonDidTapped:(id)sender
{
	if (self.actionBlock) {
		self.actionBlock();
	}
}

- (void)setRetryButtonVisible:(BOOL)isRetryButtonVisible
{
	_retryButtonVisible = isRetryButtonVisible;
	[self.retryButton setHidden:!_retryButtonVisible];
}

@end
