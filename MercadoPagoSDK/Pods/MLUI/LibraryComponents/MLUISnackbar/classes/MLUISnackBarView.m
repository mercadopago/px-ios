//
// MLUIBannerErrorView.m
// MLUI
//
// Created by Sebastián Bravo on 14/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "MLUISnackBarView.h"
#import "MLUIBundle.h"
#import "UIFont+MLFonts.h"

@interface MLUISnackBarView ()

@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic) MLUISnackBarDuration duration;

@end
@implementation MLUISnackBarView

@synthesize actionButtonBlock;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self loadViewsFromNib];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self loadViewsFromNib];
	}

	return self;
}

- (void)loadViewsFromNib
{
	UIView *view = [[[MLUIBundle mluiBundle] loadNibNamed:NSStringFromClass([MLUISnackBarView class])
	                                                owner:self
	                                              options:nil] lastObject];

	[self addSubview:view];
	view.translatesAutoresizingMaskIntoConstraints = NO;

	NSDictionary *views = @{@"view" : view};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];
}

+ (MLUISnackBarView *)snackBar:(MLUISnackBarDuration)duration
{
	MLUISnackBarView *view = [[MLUISnackBarView alloc] init];

	if (view) {
		view.duration = duration;
	}

	return view;
}

- (long)durationInMilliseconds
{
	switch (self.duration) {
		case MLSnackBarDurationShort: {
			return 2000;
			break;
		}

		case MLSnackBarDurationLong: {
			return 3500;
		}

		case MLSnackBarDurationNone: {
			return -1;
		}

		default:
			return -1;
	}
}

- (void)setMessage:(NSString *)message
{
	self.textLabel.font = [UIFont ml_thinSystemFontOfSize:kMLFontsSizeXSmall];
	[self.textLabel setText:message];
}

- (void)setActionButtonText:(NSString *)text
{
	[self.actionButton.titleLabel setFont:[UIFont ml_thinSystemFontOfSize:kMLFontsSizeXSmall]];
	[self.actionButton setTitle:text forState:UIControlStateNormal];
}

- (NSArray *)getConstraintsToSuperView
{
	NSMutableArray *constraints = [[NSMutableArray alloc] init];

	NSDictionary *views = @{@"view" : self};
	[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
	[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-0-|" options:0 metrics:nil views:views]];

	return constraints;
}

- (void)setActionButtonHidden:(BOOL)hidden
{
	self.actionButton.hidden = hidden;
}

- (IBAction)actionButtonTapped:(id)sender
{
	if (self.actionButtonBlock) {
		self.actionButtonBlock();
	}
}

@end
