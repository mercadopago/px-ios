//
// MLSpinnerConfig.m
// Pods
//
// Created by Cristian Leonel Gibert on 11/17/16.
//
//

#import "MLSpinnerConfig.h"

@implementation MLSpinnerConfig

- (instancetype)initWithSize:(MLSpinnerSize)size primaryColor:(nonnull UIColor *)primaryColor secondaryColor:(nonnull UIColor *)secondaryColor
{
	if (self = [super init]) {
		_spinnerSize = size;
		_primaryColor = primaryColor;
		_secondaryColor = secondaryColor;
	}
	return self;
}

@end
