//
// MLRadioButton.m
// MLUI
//
// Created by Santiago Lazzari on 6/7/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLRadioButton.h"

#import "UIColor+MLColorPalette.h"
#import "MLBooleanWidget_Protected.h"

static const CGFloat kMLRadioButtonInternalCircleRadiousRatio = 3 / 7.5; // If view has a radious of 7.5 then the radios has to be 1
static const CGFloat kMLRadioButtonExternalLineWidth = 2;

static const CGFloat kMLRadioButtonAnimationDuration = 0.2;
static const CGFloat kMLRadioButtonNotAnimationDuration = 0;

@interface MLRadioButton ()

@property (nonatomic, strong) CAShapeLayer *radioButtonExternalLayer;
@property (nonatomic, strong) CAShapeLayer *radioButtonInternalLayer;

@end

@implementation MLRadioButton

#pragma mark - Init
- (void)commonInit
{
	[super commonInit];
	// create external Layer
	[self.radioButtonExternalLayer removeFromSuperlayer];
	self.radioButtonExternalLayer = [CAShapeLayer layer];
	[self.layer addSublayer:self.radioButtonExternalLayer];

	// create external Layer
	[self.radioButtonInternalLayer removeFromSuperlayer];
	self.radioButtonInternalLayer = [CAShapeLayer layer];
	[self.layer addSublayer:self.radioButtonInternalLayer];
}

#pragma mark - Navigation
- (void)layoutSubviews
{
	[super layoutSubviews];

	self.radioButtonExternalLayer.frame = self.bounds;
	self.radioButtonInternalLayer.frame = self.bounds;
}

#pragma mark - Animation
- (void)setOnBooleanWidgetAnimated:(BOOL)animated
{
	if (self.isBooleanWidgetOn) {
		return;
	}

	[self fillRadioButtonExternalAnimated:animated];
	[self fillRadioButtonInternalAnimated:animated];
}

- (void)fillRadioButtonExternalAnimated:(BOOL)animated
{
	// Set circle layer bounds
	self.radioButtonExternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *externalCircle = [UIBezierPath bezierPathWithOvalInRect:self.radioButtonExternalLayer.bounds];
	self.radioButtonExternalLayer.path = externalCircle.CGPath;

	self.radioButtonExternalLayer.fillColor = [UIColor clearColor].CGColor;
	float lineWidth = kMLRadioButtonExternalLineWidth;

	self.radioButtonExternalLayer.lineWidth = lineWidth;

	// Color animation
	CABasicAnimation *colorFillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorFillAnimation.beginTime = 0;
	colorFillAnimation.fromValue = (id)[UIColor ml_meli_grey].CGColor;
	colorFillAnimation.toValue = (id)[UIColor ml_meli_blue].CGColor;
	colorFillAnimation.fillMode = kCAFillModeForwards;
	colorFillAnimation.duration = animated ? kMLRadioButtonAnimationDuration : kMLRadioButtonNotAnimationDuration;

	[self.radioButtonExternalLayer addAnimation:colorFillAnimation forKey:@"animateFill"];

	self.radioButtonExternalLayer.strokeColor = [UIColor ml_meli_blue].CGColor;
}

- (void)fillRadioButtonInternalAnimated:(BOOL)animated
{
	// Set circle layer bounds
	self.radioButtonInternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *externalCircle = [UIBezierPath bezierPathWithOvalInRect:self.radioButtonInternalLayer.bounds];
	self.radioButtonInternalLayer.path = externalCircle.CGPath;

	UIBezierPath *internalCircle = [UIBezierPath bezierPathWithOvalInRect:[self internalCircleRect]];

	self.radioButtonInternalLayer.fillColor = [UIColor ml_meli_blue].CGColor;
	float lineWidth = kMLRadioButtonExternalLineWidth;

	self.radioButtonInternalLayer.lineWidth = lineWidth;

	// Opacity animation
	CABasicAnimation *opacityFillAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityFillAnimation.beginTime = 0;
	opacityFillAnimation.fromValue = @0;
	opacityFillAnimation.toValue = @1;
	opacityFillAnimation.fillMode = kCAFillModeForwards;

	// Radius animation
	CABasicAnimation *radiusFillAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
	radiusFillAnimation.beginTime = 0;
	radiusFillAnimation.fromValue = (id)externalCircle.CGPath;
	radiusFillAnimation.toValue = (id)internalCircle.CGPath;
	radiusFillAnimation.fillMode = kCAFillModeForwards;

	// Color animation
	CABasicAnimation *colorFillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorFillAnimation.beginTime = 0;
	colorFillAnimation.fromValue = (id)[UIColor ml_meli_grey].CGColor;
	colorFillAnimation.toValue = (id)[UIColor ml_meli_blue].CGColor;
	colorFillAnimation.fillMode = kCAFillModeForwards;

	// Compaund animation
	CAAnimationGroup *fillAnimation = [CAAnimationGroup animation];
	fillAnimation.duration = animated ? kMLRadioButtonAnimationDuration : kMLRadioButtonNotAnimationDuration;
	[fillAnimation setAnimations:[NSArray arrayWithObjects:colorFillAnimation, radiusFillAnimation, opacityFillAnimation, nil]];

	[self.radioButtonInternalLayer addAnimation:fillAnimation forKey:@"animateFill"];

	self.radioButtonInternalLayer.strokeColor = [UIColor ml_meli_blue].CGColor;
	self.radioButtonInternalLayer.path = internalCircle.CGPath;
	self.radioButtonInternalLayer.opacity = 1;
}

- (void)setOffBooleanWidgetAnimated:(BOOL)animated
{
	[self clearRadioButtonExternalAnimated:animated];
	[self clearRadioButtonInternalAnimated:animated];
}

- (void)clearRadioButtonExternalAnimated:(BOOL)animated
{
	// Set circle layer bounds
	self.radioButtonExternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *externalCircle = [UIBezierPath bezierPathWithOvalInRect:self.radioButtonExternalLayer.bounds];
	self.radioButtonExternalLayer.path = externalCircle.CGPath;

	self.radioButtonExternalLayer.fillColor = [UIColor clearColor].CGColor;
	float lineWidth = kMLRadioButtonExternalLineWidth;

	self.radioButtonExternalLayer.lineWidth = lineWidth;

	// Color animation
	CABasicAnimation *colorFillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorFillAnimation.beginTime = 0;
	colorFillAnimation.fromValue = (id)[UIColor ml_meli_blue].CGColor;
	colorFillAnimation.toValue = (id)[UIColor ml_meli_grey].CGColor;
	colorFillAnimation.fillMode = kCAFillModeForwards;
	colorFillAnimation.duration = animated ? kMLRadioButtonAnimationDuration : kMLRadioButtonNotAnimationDuration;

	[self.radioButtonExternalLayer addAnimation:colorFillAnimation forKey:@"animateFill"];

	self.radioButtonExternalLayer.strokeColor = [UIColor ml_meli_grey].CGColor;
}

- (void)clearRadioButtonInternalAnimated:(BOOL)animated
{
	// Set circle layer bounds
	self.radioButtonInternalLayer.bounds = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame));

	// Set circle layer path
	UIBezierPath *externalCircle = [UIBezierPath bezierPathWithOvalInRect:self.radioButtonInternalLayer.bounds];

	UIBezierPath *internalCircle = [UIBezierPath bezierPathWithOvalInRect:[self internalCircleRect]];
	[internalCircle fill];

	self.radioButtonInternalLayer.path = internalCircle.CGPath;

	self.radioButtonInternalLayer.fillColor = [UIColor clearColor].CGColor;
	float lineWidth = kMLRadioButtonExternalLineWidth;
	self.radioButtonInternalLayer.lineWidth = lineWidth;

	// Opacity animation
	CABasicAnimation *opacityClearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityClearAnimation.beginTime = 0;
	opacityClearAnimation.fromValue = @1;
	opacityClearAnimation.toValue = @0;
	opacityClearAnimation.fillMode = kCAFillModeForwards;

	// Radius animation
	CABasicAnimation *radiusClearAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
	radiusClearAnimation.beginTime = 0;
	radiusClearAnimation.fromValue = (id)internalCircle.CGPath;
	radiusClearAnimation.toValue = (id)externalCircle.CGPath;
	radiusClearAnimation.fillMode = kCAFillModeForwards;

	// Color animation
	CABasicAnimation *colorClearAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
	colorClearAnimation.beginTime = 0;
	colorClearAnimation.fromValue = (id)[UIColor ml_meli_blue].CGColor;
	colorClearAnimation.toValue = (id)[UIColor ml_meli_grey].CGColor;
	colorClearAnimation.fillMode = kCAFillModeForwards;

	// Compaund animation
	CAAnimationGroup *clearAnimation = [CAAnimationGroup animation];
	clearAnimation.duration = animated ? kMLRadioButtonAnimationDuration : kMLRadioButtonNotAnimationDuration;
	[clearAnimation setAnimations:[NSArray arrayWithObjects:radiusClearAnimation, colorClearAnimation, opacityClearAnimation, nil]];

	[self.radioButtonInternalLayer addAnimation:clearAnimation forKey:@"animateClear"];

	self.radioButtonInternalLayer.strokeColor = [UIColor ml_meli_grey].CGColor;
	self.radioButtonInternalLayer.path = externalCircle.CGPath;
	self.radioButtonInternalLayer.opacity = 0;
}

- (CGRect)internalCircleRect
{
	CGFloat internalRadius = [self internalCircleRadius];

	CGFloat x = (CGRectGetWidth(self.radioButtonInternalLayer.bounds) - 2 * internalRadius) / 2.0;
	CGFloat y = (CGRectGetHeight(self.radioButtonInternalLayer.bounds) - 2 * internalRadius) / 2.0;

	CGFloat width = 2 * internalRadius;
	CGFloat height = 2 * internalRadius;

	return CGRectMake(x, y, width, height);
}

- (CGFloat)internalCircleRadius
{
	CGFloat rectRadius = CGRectGetWidth(self.frame) / 2.0f;
	CGFloat internalRadious = rectRadius * kMLRadioButtonInternalCircleRadiousRatio;

	return internalRadious;
}

@end
