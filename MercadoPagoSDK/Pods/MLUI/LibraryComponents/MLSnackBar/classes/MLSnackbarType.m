//
// MLSnackbarType.m
// MLUI
//
// Created by Julieta Puente on 26/2/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLSnackbarType.h"
#import "UIColor+MLColorPalette.h"
#import "MLStyleSheetManager.h"

@implementation MLSnackbarType

- (instancetype)init
{
	self = [super init];
	if (self) {
		_backgroundColor = MLStyleSheetManager.styleSheet.blackColor;
		_titleFontColor = MLStyleSheetManager.styleSheet.whiteColor;
		_actionFontColor = MLStyleSheetManager.styleSheet.whiteColor;
		_actionFontHighlightColor = MLStyleSheetManager.styleSheet.whiteColor;
		_actionBackgroundHighlightColor = [UIColor colorWithRed:0.f / 255.f green:0.f / 255.f blue:0.f / 255.f alpha:0.1];
	}
	return self;
}

+ (instancetype)defaultType
{
	return [[self alloc] init];
}

+ (instancetype)successType
{
	MLSnackbarType *successType = [self defaultType];
	successType.backgroundColor = MLStyleSheetManager.styleSheet.successColor;
	return successType;
}

+ (instancetype)warningType
{
	MLSnackbarType *warningType = [self defaultType];
	warningType.backgroundColor = MLStyleSheetManager.styleSheet.warningColor;
	return warningType;
}

+ (instancetype)errorType
{
	MLSnackbarType *errorType = [self defaultType];
	errorType.backgroundColor = MLStyleSheetManager.styleSheet.errorColor;
	return errorType;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	_backgroundColor = backgroundColor;
}

@end
