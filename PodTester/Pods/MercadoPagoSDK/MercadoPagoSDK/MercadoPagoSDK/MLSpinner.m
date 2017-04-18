//
// MLSpinner.m
// MLUI
//
// Created by Julieta Puente on 18/4/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLSpinner.h"
#import <MercadoPagoSDK/MercadoPagoSDK-Swift.h>


@interface MLSpinner ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic) CGFloat diameter;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic) MLSpinnerStyle style;
@property (nonatomic, copy) NSString *spinnerText;
@property (nonatomic) BOOL allowsText;
@property (nonatomic, strong) UIView *view;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spinnerLabelVerticalSpacing;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spinnerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spinnerHeightConstraint;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL shouldHide;
@property (nonatomic) BOOL shouldShow;
@property (nonatomic) BOOL isHidden;

@end

@implementation MLSpinner

static const CGFloat kMLSpinnerStrokeAnimationDuration = 0.75;
static const CGFloat kMLSpinnerColorAnimationDuration = 0.1;
static const CGFloat kMLSpinnerStrokeStartBegin = 0.5;
static const CGFloat kMLSpinnerCycleAnimationDuration = kMLSpinnerStrokeAnimationDuration + kMLSpinnerStrokeStartBegin;
static const CGFloat kMLSpinnerRotationDuration = 2.0;
static const CGFloat kMLSpinnerLabelVerticalSpacing = 32;
static const CGFloat kMLSpinnerSmallDiameter = 20;
static const CGFloat kMLSpinnerBigDiameter = 60;
static const CGFloat kMLSpinnerSmallLineWidth = 2;
static const CGFloat kMLSpinnerBigLineWidth = 3;
static const CGFloat kMLSpinnerAppearenceAnimationDuration = 0.3;

- (id)init
{
	if (self = [self initWithConfig:[self setUpConfigFromStyle:MLSpinnerStyleBlueBig] text:nil]) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

- (id)initWithStyle:(MLSpinnerStyle)style
{
	if (self = [self initWithConfig:[self setUpConfigFromStyle:self.style] text:nil]) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

- (id)initWithStyle:(MLSpinnerStyle)style text:(NSString *)text
{
	if (self = [self initWithConfig:[self setUpConfigFromStyle:self.style] text:text]) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return self;
}

- (id)initWithConfig:(nonnull MLSpinnerConfig *)config text:(NSString *)text
{
	if (self = [super init]) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.spinnerText = text;
		[self setUpView];
		[self setUpSpinnerWithConfig:config];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.style = MLSpinnerStyleBlueBig;
		[self setUpView];
	}
	return self;
}

- (void)loadView
{
	UIView *view = [[MercadoPago getBundle] loadNibNamed:NSStringFromClass([MLSpinner class])
		                                         owner:self
		                                       options:nil].firstObject;
	self.view = view;

	view.translatesAutoresizingMaskIntoConstraints = NO;
	view.backgroundColor = [UIColor clearColor];

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

- (void)setUpView
{
	// get view from xib
	[self loadView];

	// set view to default values
	self.containerView.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.text = nil;
	self.label.font = [UIFont fontWithName:@"ProximaNova-Light" size:24.0f];
	self.spinnerView.backgroundColor = [UIColor clearColor];
	self.view.alpha = 0;
	self.isHidden = YES;

	// create spinner layer
	self.circleLayer = [CAShapeLayer layer];
	[self.spinnerView.layer addSublayer:self.circleLayer];
}

- (MLSpinnerConfig *)setUpConfigFromStyle:(MLSpinnerStyle)style
{
	MLSpinnerConfig *config;
	switch (style) {
		case MLSpinnerStyleBlueBig: {
			config = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeBig primaryColor:[UIColor colorWithRed:255.f / 255.f green:219.f / 255.f blue:21.f / 255.f alpha:1] secondaryColor:[UIColor colorWithRed:52.f / 255.f green:131.f / 255.f blue:250.f / 255.f alpha:1]];
		}
		break;

		case MLSpinnerStyleWhiteBig: {
			config = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeBig primaryColor:[UIColor colorWithRed:255.f / 255.f green:255.f / 255.f blue:255.f / 255.f alpha:1] secondaryColor:[UIColor colorWithRed:52.f / 255.f green:131.f / 255.f blue:250.f / 255.f alpha:1]];
		}
		break;

		case MLSpinnerStyleBlueSmall: {
			config = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeSmall primaryColor:[UIColor colorWithRed:52.f / 255.f green:131.f / 255.f blue:250.f / 255.f alpha:1] secondaryColor:[UIColor colorWithRed:52.f / 255.f green:131.f / 255.f blue:250.f / 255.f alpha:1]];
		}
		break;

		case MLSpinnerStyleWhiteSmall: {
			config = [[MLSpinnerConfig alloc] initWithSize:MLSpinnerSizeSmall primaryColor:[UIColor colorWithRed:255.f / 255.f green:255.f / 255.f blue:255.f / 255.f alpha:1] secondaryColor:[UIColor colorWithRed:255.f / 255.f green:255.f / 255.f blue:255.f / 255.f alpha:1]];
		}
		break;

		default: {
		}
		break;
	}
	return config;
}

- (void)setUpSpinnerWithConfig:(MLSpinnerConfig *)config
{
	self.endColor = config.secondaryColor;
	self.startColor = config.primaryColor;
	self.allowsText = config.spinnerSize == MLSpinnerSizeBig ? YES : NO;
	self.diameter = config.spinnerSize == MLSpinnerSizeBig ? kMLSpinnerBigDiameter : kMLSpinnerSmallDiameter;
	self.spinnerWidthConstraint.constant = config.spinnerSize == MLSpinnerSizeBig ? kMLSpinnerBigDiameter : kMLSpinnerSmallDiameter;
	self.spinnerHeightConstraint.constant = config.spinnerSize == MLSpinnerSizeBig ? kMLSpinnerBigDiameter : kMLSpinnerSmallDiameter;
	self.lineWidth = config.spinnerSize == MLSpinnerSizeBig ? kMLSpinnerBigLineWidth : kMLSpinnerSmallLineWidth;

	if (self.spinnerView) {
		// If we don't use performSelector, the spinner animation is not visible when the controller is presented
		[self performSelector:@selector(setUpLayer) withObject:nil afterDelay:0];
		[self performSelector:@selector(setUpLabel) withObject:nil afterDelay:0];
	}
}

- (void)setUpLayer
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];

	// Set circle layer bounds
	self.circleLayer.bounds = CGRectMake(0, 0, self.diameter, self.diameter);
	CGSize size = [self.spinnerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
	self.circleLayer.position = CGPointMake(size.width / 2, size.height / 2);

	// Set circle layer path
	UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:self.circleLayer.bounds];
	self.circleLayer.path = circle.CGPath;

	self.circleLayer.fillColor = [UIColor clearColor].CGColor;
	self.circleLayer.lineWidth = self.lineWidth;

	[CATransaction commit];

	// Stroke animation
	CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	strokeEndAnimation.duration = kMLSpinnerStrokeAnimationDuration;
	strokeEndAnimation.beginTime = 0;
	strokeEndAnimation.fromValue = @0;
	strokeEndAnimation.toValue = @1;

	CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
	strokeStartAnimation.duration = kMLSpinnerStrokeAnimationDuration;
	strokeStartAnimation.beginTime = kMLSpinnerStrokeStartBegin;
	strokeStartAnimation.fromValue = @0;
	strokeStartAnimation.toValue = @1;

	CAAnimationGroup *strokeAnimationGroup = [CAAnimationGroup animation];
	strokeAnimationGroup.duration = kMLSpinnerCycleAnimationDuration;
	strokeAnimationGroup.repeatCount = INFINITY;
	[strokeAnimationGroup setAnimations:[NSArray arrayWithObjects:strokeEndAnimation, strokeStartAnimation, nil]];

	// Color animation
	CABasicAnimation *colorEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorEndAnimation.duration = kMLSpinnerColorAnimationDuration;
	colorEndAnimation.beginTime = 0;
	colorEndAnimation.toValue = (id)self.endColor.CGColor;
	colorEndAnimation.fillMode = kCAFillModeForwards;
	colorEndAnimation.timeOffset = 0;

	CABasicAnimation *colorStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorStartAnimation.duration = kMLSpinnerColorAnimationDuration;
	colorStartAnimation.beginTime = kMLSpinnerCycleAnimationDuration;
	colorStartAnimation.toValue = (id)self.startColor.CGColor;
	colorStartAnimation.fillMode = kCAFillModeForwards;
	colorStartAnimation.timeOffset = 0;

	CAAnimationGroup *colorAnimationGroup = [CAAnimationGroup animation];
	colorAnimationGroup.duration = kMLSpinnerCycleAnimationDuration * 2;
	colorAnimationGroup.repeatCount = INFINITY;
	[colorAnimationGroup setAnimations:[NSArray arrayWithObjects:colorEndAnimation, colorStartAnimation, nil]];

	// Rotation animation
	CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotateAnimation.duration = kMLSpinnerRotationDuration;
	rotateAnimation.fromValue = @0;
	rotateAnimation.toValue = [NSNumber numberWithDouble:2 * M_PI];
	rotateAnimation.repeatCount = INFINITY;
	rotateAnimation.fillMode = kCAFillModeForwards;
	rotateAnimation.additive = YES;

	colorAnimationGroup.delegate = self;
	colorAnimationGroup.removedOnCompletion = NO;
	strokeAnimationGroup.delegate = self;
	strokeAnimationGroup.removedOnCompletion = NO;
	rotateAnimation.delegate = self;
	rotateAnimation.removedOnCompletion = NO;

	[self.circleLayer addAnimation:strokeAnimationGroup forKey:@"animateStroke"];
	[self.circleLayer addAnimation:colorAnimationGroup forKey:@"animateColor"];
	[self.circleLayer addAnimation:rotateAnimation forKey:@"animateRotation"];
}

- (void)setUpLabel
{
	if (self.allowsText && self.spinnerText) {
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		paragraphStyle.lineSpacing = 5;
		paragraphStyle.alignment = NSTextAlignmentCenter;

		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.spinnerText];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.spinnerText.length)];

		self.label.attributedText = attributedString;
		self.spinnerLabelVerticalSpacing.constant = kMLSpinnerLabelVerticalSpacing;
	} else {
		self.spinnerLabelVerticalSpacing.constant = 0;
		self.label.text = @"";
	}
}

- (void)setText:(NSString *)spinnerText
{
	_spinnerText = spinnerText;
	[self setUpLabel];
}

- (void)setStyle:(MLSpinnerStyle)style
{
	_style = style;
	[self setUpSpinnerWithConfig:[self setUpConfigFromStyle:style]];
}

- (void)showSpinner
{
	if (!self.isHidden) {
		return;
	}

	self.shouldShow = YES;

	__weak typeof(self) weakSelf = self;

	if (!self.isAnimating) {
		self.isHidden = NO;

		self.view.alpha = 0;
		weakSelf.isAnimating = YES;
		[UIView animateWithDuration:kMLSpinnerAppearenceAnimationDuration animations: ^{
		    weakSelf.view.alpha = 1;
		} completion: ^(BOOL finished) {
		    weakSelf.isAnimating = NO;
		    weakSelf.shouldShow = NO;

		    if (weakSelf.shouldHide) {
		        [weakSelf hideSpinner];
			}
		}];
	}
}

- (void)hideSpinner
{
	if (self.isHidden) {
		return;
	}

	__weak typeof(self) weakSelf = self;

	self.shouldHide = YES;
	if (!self.isAnimating) {
		self.isHidden = YES;

		weakSelf.isAnimating = YES;
		[UIView animateWithDuration:kMLSpinnerAppearenceAnimationDuration animations: ^{
		    weakSelf.view.alpha = 0;
		} completion: ^(BOOL finished) {
		    weakSelf.isAnimating = NO;
		    weakSelf.shouldHide = NO;
		    if (weakSelf.shouldShow) {
		        [weakSelf showSpinner];
			}
		}];
	}
}

@end
