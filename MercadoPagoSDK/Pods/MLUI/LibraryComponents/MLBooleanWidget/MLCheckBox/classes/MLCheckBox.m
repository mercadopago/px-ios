//
// MLcheckBox.m
// MLUI
//
// Created by Santiago Lazzari on 6/14/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLCheckBox.h"

#import "UIColor+MLColorPalette.h"
#import "MLBooleanWidget_Protected.h"

static const CGFloat kMLCheckBoxExternalLineWidth = 2;
static const CGFloat kMLCheckBoxExternalCornerRadius = 1;

static const CGFloat kMLCheckBoxTickLineWidth = 2;

static const CGFloat kMLCheckBoxAnimationDuration = 0.2;
static const CGFloat kMLCheckBoxNotAnimationDuration = 0;

@interface MLCheckBox ()

@property (nonatomic, strong) CAShapeLayer *checkBoxExternalLayer;
@property (nonatomic, strong) CAShapeLayer *checkBoxInternalLayer;
@property (nonatomic, strong) CAShapeLayer *checkBoxTickLayer;

@end

@implementation MLCheckBox

#pragma mark - Init

- (void)commonInit
{
	[super commonInit];

	// create external Layer
	[self.checkBoxExternalLayer removeFromSuperlayer];
	self.checkBoxExternalLayer = [CAShapeLayer layer];
	[self.layer addSublayer:self.checkBoxExternalLayer];

	// create external Layer
	[self.checkBoxInternalLayer removeFromSuperlayer];
	self.checkBoxInternalLayer = [CAShapeLayer layer];
	[self.layer addSublayer:self.checkBoxInternalLayer];

	// create tick layer
	self.checkBoxTickLayer = [CAShapeLayer layer];
	[self.layer addSublayer:self.checkBoxTickLayer];
}

#pragma mark - Navigation
- (void)layoutSubviews
{
	[super layoutSubviews];

	self.checkBoxTickLayer.frame = self.bounds;
	self.checkBoxExternalLayer.frame = self.bounds;
	self.checkBoxInternalLayer.frame = self.bounds;
}

#pragma mark - Public Methods
- (void)setEnabled:(BOOL)enabled Animated:(BOOL)animated
{
	[super setEnabled:enabled Animated:animated];
	if (enabled) {
		if (self.isBooleanWidgetOn) {
			[self fillCheckBoxExternalFromColor:[self disabledColor] ToColor:[self enabledOnColor] Animated:animated];
			[self fillCheckBoxInternalFromColor:[self disabledColor] ToColor:[self enabledOnColor] FromOpacity:1 ToOpacity:1 Animated:animated];
		} else {
			[self fillCheckBoxExternalFromColor:[self disabledColor] ToColor:[self enabledOffColor] Animated:animated];
			[self fillCheckBoxInternalFromColor:[self disabledColor] ToColor:[self enabledOffColor] FromOpacity:0 ToOpacity:0 Animated:animated];
		}
	} else {
		if (self.isBooleanWidgetOn) {
			[self fillCheckBoxExternalFromColor:[self enabledOnColor] ToColor:[self disabledColor] Animated:animated];
			[self fillCheckBoxInternalFromColor:[self enabledOnColor] ToColor:[self disabledColor] FromOpacity:1 ToOpacity:1 Animated:animated];
		} else {
			[self fillCheckBoxExternalFromColor:[self enabledOffColor] ToColor:[self disabledColor] Animated:animated];
			[self fillCheckBoxInternalFromColor:[self enabledOffColor] ToColor:[self disabledColor] FromOpacity:0 ToOpacity:0 Animated:animated];
		}
	}
}

#pragma mark - Animation

- (void)setOnBooleanWidgetAnimated:(BOOL)animated
{
	if (self.isBooleanWidgetOn || !self.isEnabled) {
		return;
	}

	[self fillCheckBoxExternalAnimated:animated];
	[self fillCheckBoxInternalFromColor:[self enabledOffColor] ToColor:[self enabledOnColor] FromOpacity:0 ToOpacity:1 Animated:animated];
	[self fillCheckBoxTickAnimated:animated];
}

- (void)fillCheckBoxExternalFromColor:(UIColor *)fromColor ToColor:(UIColor *)toColor Animated:(BOOL)animated
{
	// Set circle layer bounds
	self.checkBoxExternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *externalFrame = [UIBezierPath bezierPathWithRoundedRect:self.checkBoxExternalLayer.bounds cornerRadius:kMLCheckBoxExternalCornerRadius];
	self.checkBoxExternalLayer.path = externalFrame.CGPath;

	self.checkBoxExternalLayer.fillColor = [UIColor clearColor].CGColor;
	self.checkBoxExternalLayer.lineWidth = kMLCheckBoxExternalLineWidth;

	// Color animation
	CABasicAnimation *colorFillAnimation = [self createColorFillAnimationFromColor:fromColor ToColor:toColor WithDuration:animated ? kMLCheckBoxAnimationDuration : kMLCheckBoxNotAnimationDuration];

	[self.checkBoxExternalLayer addAnimation:colorFillAnimation forKey:@"animateFill"];

	self.checkBoxExternalLayer.strokeColor = toColor.CGColor;
}

- (void)fillCheckBoxExternalAnimated:(BOOL)animated
{
	[self fillCheckBoxExternalFromColor:[self enabledOffColor] ToColor:[self enabledOnColor] Animated:animated];
}

- (void)fillCheckBoxInternalFromColor:(UIColor *)fromColor ToColor:(UIColor *)toColor FromOpacity:(float)fromOpacity ToOpacity:(float)toOpacity Animated:(BOOL)animated
{
	// Set circle layer bounds
	self.checkBoxInternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *internalFrame = [UIBezierPath bezierPathWithRoundedRect:self.checkBoxExternalLayer.bounds cornerRadius:kMLCheckBoxExternalCornerRadius];
	self.checkBoxInternalLayer.path = internalFrame.CGPath;

	self.checkBoxInternalLayer.fillColor = toOpacity == 0 ? [UIColor clearColor].CGColor : toColor.CGColor;
	float lineWidth = kMLCheckBoxExternalLineWidth;

	self.checkBoxInternalLayer.lineWidth = lineWidth;

	// Opacity animation
	CABasicAnimation *opacityFillAnimation = [self createOpacityFillAnimationFromValue:fromOpacity ToValue:toOpacity];

	// Color animation
	CABasicAnimation *colorFillAnimation = [self createColorFillAnimationFromColor:fromColor ToColor:toColor];

	// Compaund animation
	CAAnimationGroup *fillAnimation = [CAAnimationGroup animation];
	fillAnimation.duration = animated ? kMLCheckBoxAnimationDuration : kMLCheckBoxNotAnimationDuration;
	[fillAnimation setAnimations:[NSArray arrayWithObjects:colorFillAnimation, opacityFillAnimation, nil]];

	[self.checkBoxInternalLayer addAnimation:fillAnimation forKey:@"animateFill"];

	self.checkBoxInternalLayer.strokeColor = toColor.CGColor;
}

- (void)fillCheckBoxTickAnimated:(BOOL)animated
{
	// Set circle layer bounds
	self.checkBoxTickLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *tickPath = [UIBezierPath bezierPath];

	[tickPath moveToPoint:[self tickLeftPointInRect:self.bounds]];
	[tickPath addLineToPoint:[self tickBotomPointInRect:self.bounds]];
	[tickPath addLineToPoint:[self tickRightPointInRect:self.bounds]];

	self.checkBoxTickLayer.path = tickPath.CGPath;

	self.checkBoxTickLayer.strokeColor = [UIColor ml_meli_white].CGColor;
	self.checkBoxTickLayer.fillColor = [UIColor clearColor].CGColor;
	float lineWidth = kMLCheckBoxTickLineWidth;

	self.checkBoxTickLayer.lineWidth = lineWidth;

	// Color animation
	CABasicAnimation *pathTickAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	pathTickAnimation.fromValue = @0.0;
	pathTickAnimation.toValue = @1.0;
	pathTickAnimation.fillMode = kCAFillModeForwards;
	pathTickAnimation.duration = animated ? kMLCheckBoxAnimationDuration : kMLCheckBoxNotAnimationDuration;

	[self.checkBoxTickLayer addAnimation:pathTickAnimation forKey:@"animateFillTick"];
}

- (void)setOffBooleanWidgetAnimated:(BOOL)animated
{
	if (!self.isEnabled) {
		return;
	}

	[self fillCheckBoxExternalFromColor:[self enabledOnColor] ToColor:[self enabledOffColor] Animated:animated];
	[self fillCheckBoxInternalFromColor:[self enabledOnColor] ToColor:[self enabledOffColor] FromOpacity:1 ToOpacity:0 Animated:animated];
}

#pragma mark - Tick Positions
- (CGPoint)tickLeftPointInRect:(CGRect)rect
{
	CGFloat x = rect.size.width * (2.5 / 15.0);
	CGFloat y = rect.size.height / 2.0;

	return CGPointMake(x, y);
}

- (CGPoint)tickBotomPointInRect:(CGRect)rect
{
	CGFloat x = rect.size.width * (1.0 / 3.0);
	CGFloat y = rect.size.height * (2.0 / 3.0);

	return CGPointMake(x, y);
}

- (CGPoint)tickRightPointInRect:(CGRect)rect
{
	CGFloat x = rect.size.width - (rect.size.width * (2.5 / 15.0));
	CGFloat y = rect.size.height / 4.0;

	return CGPointMake(x, y);
}

- (CABasicAnimation *)createOpacityFillAnimationFromValue:(float)fromValue ToValue:(float)toValue
{
	return [self createOpacityFillAnimationFromValue:fromValue ToValue:toValue WithDuration:0 WithFillMode:kCAFillModeForwards];
}

- (CABasicAnimation *)createOpacityFillAnimationFromValue:(float)fromValue ToValue:(float)toValue WithDuration:(double)duration
{
	return [self createOpacityFillAnimationFromValue:fromValue ToValue:toValue WithDuration:duration WithFillMode:kCAFillModeForwards];
}

- (CABasicAnimation *)createOpacityFillAnimationFromValue:(float)fromValue ToValue:(float)toValue WithDuration:(double)duration WithFillMode:(NSString *)fillMode
{
	CABasicAnimation *opacityFillAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityFillAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
	opacityFillAnimation.toValue = [NSNumber numberWithFloat:toValue];
	opacityFillAnimation.duration = duration;
	opacityFillAnimation.fillMode = fillMode;

	return opacityFillAnimation;
}

- (CABasicAnimation *)createColorFillAnimationFromColor:(UIColor *)fromColor ToColor:(UIColor *)toColor WithDuration:(double)duration
{
	return [self createColorFillAnimationFromColor:fromColor ToColor:toColor WithDuration:duration WithFillMode:kCAFillModeForwards];
}

- (CABasicAnimation *)createColorFillAnimationFromColor:(UIColor *)fromColor ToColor:(UIColor *)toColor
{
	return [self createColorFillAnimationFromColor:fromColor ToColor:toColor WithDuration:0 WithFillMode:kCAFillModeForwards];
}

- (CABasicAnimation *)createColorFillAnimationFromColor:(UIColor *)fromColor ToColor:(UIColor *)toColor WithDuration:(double)duration WithFillMode:(NSString *)fillMode
{
	CABasicAnimation *colorFillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorFillAnimation.fromValue = (id)fromColor.CGColor;
	colorFillAnimation.toValue = (id)toColor.CGColor;
	colorFillAnimation.duration = duration;
	colorFillAnimation.fillMode = fillMode;

	return colorFillAnimation;
}

#pragma mark - Color Getter Methods
- (UIColor *)enabledOnColor
{
	return [UIColor ml_meli_blue];
}

- (UIColor *)enabledOffColor
{
	return [UIColor ml_meli_grey];
}

- (UIColor *)disabledColor
{
	return [UIColor ml_meli_mid_grey];
}

@end
