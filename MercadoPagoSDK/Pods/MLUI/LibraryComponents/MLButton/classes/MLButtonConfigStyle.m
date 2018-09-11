//
// MLButtonConfigStyle.m
// Pods
//
// Created by Cristian Leonel Gibert on 1/12/17.
//
//

#import "MLButtonConfigStyle.h"

@implementation MLButtonConfigStyle

- (instancetype)initWithContentColor:(UIColor *)contentColor backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor
{
	if (self = [super init]) {
		_contentColor = contentColor;
		_backgroundColor = backgroundColor;
		_borderColor = borderColor;
	}
	return self;
}

- (BOOL)isEqualToButtonConfigStyle:(MLButtonConfigStyle *)buttonConfigStyle
{
	if (!buttonConfigStyle) {
		return NO;
	}
	BOOL haveEqualContentColor = (!self.contentColor && !buttonConfigStyle.contentColor) || [self.contentColor isEqual:buttonConfigStyle.contentColor];
	BOOL haveEqualBackgroundColor = (!self.backgroundColor && !buttonConfigStyle.backgroundColor) || [self.backgroundColor isEqual:buttonConfigStyle.backgroundColor];
	BOOL haveEqualBorderColor = (!self.borderColor && !buttonConfigStyle.borderColor) || [self.borderColor isEqual:buttonConfigStyle.borderColor];
	return haveEqualContentColor && haveEqualBackgroundColor && haveEqualBorderColor;
}

- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	if (![object isKindOfClass:MLButtonConfigStyle.class]) {
		return NO;
	}
	return [self isEqualToButtonConfigStyle:(MLButtonConfigStyle *)object];
}

- (NSUInteger)hash
{
	return self.contentColor.hash ^ self.backgroundColor.hash ^ self.borderColor.hash;
}

@end
