//
// MLSwitch.m
// MLUI
//
// Created by Santiago Lazzari on 6/16/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLSwitch.h"
#import "MLUIBundle.h"
#import "MLBooleanWidget_Protected.h"
#import "UIColor+MLColorPalette.h"

static const CGFloat kMLSwitchAnimationDuration = 0.2;
static const CGFloat kMLSwitchButtonNotAnimationDuration = 0;

@interface MLSwitch ()

@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UIView *trackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleLeftConstraint;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic) BOOL isInitialized;

@end

@implementation MLSwitch

#pragma mark - Init
- (instancetype)init
{
	if (self = [super init]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self commonInit];
	}

	return self;
}

- (void)commonInit
{
	[super commonInit];

	[self setupXib];
	[self setupTrackView];
	[self setupCircleView];
	[self setupLongPressGestureRecognizer];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self layoutCircle];
	[self layoutTrack];
}

#pragma mark - Setup
- (void)setupXib
{
	if (!self.isInitialized) {
		[[MLUIBundle mluiBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];

		self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
		self.view.backgroundColor = [UIColor clearColor];
		[self addSubview:self.view];
		self.isInitialized = YES;
	}
}

- (void)setupTrackView
{
	[self layoutTrack];
}

- (void)setupCircleView
{
	[self layoutCircle];
}

- (void)setupLongPressGestureRecognizer
{
	UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(switchDidLongPressTouch:)];
	longPressGR.minimumPressDuration = 0.1;

	[self addGestureRecognizer:longPressGR];
}

#pragma mark - Layout
- (void)layoutTrack
{
	CGFloat height = CGRectGetHeight(self.trackView.frame);

	self.trackView.layer.cornerRadius = height / 2.0f;
}

- (void)layoutCircle
{
	CGFloat height = CGRectGetHeight(self.circleView.frame);

	[self.circleView.layer setBorderColor:[[UIColor ml_meli_dark_grey] CGColor]];
	[self.circleView.layer setShadowColor:[[UIColor blackColor] CGColor]];
	[self.circleView.layer setShadowOpacity:0.5];
	[self.circleView.layer setShadowRadius:1.5];
	[self.circleView.layer setShadowOffset:CGSizeMake(0, 3)];

	self.circleView.layer.cornerRadius = height / 2.0f;
}

#pragma mark - MLSelectionWidget

- (void)setOnBooleanWidgetAnimated:(BOOL)animated
{
	__weak typeof(self)weakSelf = self;

	CGFloat circleWidth = CGRectGetWidth(self.circleView.frame);
	CGFloat switchWidth = CGRectGetWidth(self.frame);

	self.circleLeftConstraint.constant = switchWidth - circleWidth;

	[UIView animateWithDuration:animated ? kMLSwitchAnimationDuration : kMLSwitchButtonNotAnimationDuration animations: ^{
	    [weakSelf layoutIfNeeded];

	    [weakSelf.trackView setBackgroundColor:[UIColor colorWithRed:0.835f green:0.898f blue:1.0f alpha:1.0f]];
	    [weakSelf.circleView setBackgroundColor:[UIColor ml_meli_blue]];
	}];
}

- (void)setOffBooleanWidgetAnimated:(BOOL)animated
{
	__weak typeof(self)weakSelf = self;

	self.circleLeftConstraint.constant = 0;

	[UIView animateWithDuration:animated ? kMLSwitchAnimationDuration : kMLSwitchButtonNotAnimationDuration animations: ^{
	    [weakSelf layoutIfNeeded];

	    [weakSelf.trackView setBackgroundColor:[UIColor ml_meli_grey]];
	    [weakSelf.circleView setBackgroundColor:[UIColor ml_meli_light_grey]];
	}];
}

#pragma mark - Actions
- (void)switchDidLongPressTouch:(UILongPressGestureRecognizer *)sender
{
	CGFloat x = [sender locationInView:self].x;
	CGFloat circleWidth = CGRectGetWidth(self.circleView.frame);
	CGFloat circleViewEstimatedPosition = x - circleWidth / 2.0f;

	CGFloat rightLimit = CGRectGetWidth(self.frame) - circleWidth;
	CGFloat leftLimit = 0;

	if (sender.state == UIGestureRecognizerStateEnded) {
		BOOL onCondition = x > CGRectGetWidth(self.frame) / 2.0f;

// If state has changed
		if (onCondition != [self isOn]) {
			if ([self.delegate respondsToSelector:@selector(booleanWidgetDidRequestChangeOfState:)]) {
				[self.delegate booleanWidgetDidRequestChangeOfState:self];
			}
// If state has not changed but need to restore to current value, and this value is Off
		} else if ([self isOff]) {
			[self setOffBooleanWidgetAnimated:YES];
// If state has not changed but need to restore to current value, and this value is On
		} else {
			[self setOnBooleanWidgetAnimated:YES];
		}

		return;
	}

	// Limit the circleView in switch bounds
	if (circleViewEstimatedPosition > rightLimit || circleViewEstimatedPosition < leftLimit) {
		return;
	}

	self.circleLeftConstraint.constant = circleViewEstimatedPosition;
}

@end
