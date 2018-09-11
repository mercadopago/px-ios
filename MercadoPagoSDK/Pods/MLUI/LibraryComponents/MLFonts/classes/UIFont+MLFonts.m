//
// UIFont+MLFonts.m
// MLUI
//
// Created by Julieta Puente on 12/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "UIFont+MLFonts.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"
#import "UILabel+MLFonts.h"
#import "UITextView+MLFonts.h"
#import "MLUIBundle.h"
#import "MLStyleSheetManager.h"

const int kMLFontsSizeXXLarge = 32.0f;
const int kMLFontsSizeXLarge = 24.0f;
const int kMLFontsSizeLarge = 20.0f;
const int kMLFontsSizeMedium = 18.0f;
const int kMLFontsSizeSmall = 16.0f;
const int kMLFontsSizeXSmall = 14.0f;
const int kMLFontsSizeXXSmall = 12.0f;

const CGFloat MLFontWeightThin = -0.500000;
const CGFloat MLFontWeightLight = -0.200000;
const CGFloat MLFontWeightRegular = 0.000000;
const CGFloat MLFontWeightMedium = 0.200000;
const CGFloat MLFontWeightSemibold = 0.300000;
const CGFloat MLFontWeightBold = 0.400000;
const CGFloat MLFontWeightHeavy = 0.560000;
const CGFloat MLFontWeightBlack = 0.620000;

@implementation UIFont (MLFonts)

+ (void)load
{
#ifdef MLUI_OVERRIDE_FONT
	SEL original = @selector(systemFontOfSize:);
	SEL modified = @selector(ml_regularSwizzledSystemFontOfSize:);
	SEL originalBold = @selector(boldSystemFontOfSize:);
	SEL modifiedBold = @selector(ml_boldSwizzledSystemFontOfSize:);

	// Swizzle systemFont method for ml_systemFont method
	[self jr_swizzleClassMethod:originalBold withClassMethod:modifiedBold error:nil];
	[self jr_swizzleClassMethod:original withClassMethod:modified error:nil];

	[self ml_setViewComponentesSystemFont];
#else
	NSLog(@"Won't override system fonts with meli fonts - UIFont");
#endif
}

+ (void)ml_setViewComponentesSystemFont
{
	[[UILabel appearance] ml_shouldSetSystemFont:YES];
	[[UITextView appearance] ml_shouldSetSystemFont:YES];
}

+ (UIFont *)ml_regularSwizzledSystemFontOfSize:(CGFloat)size
{
	return [MLStyleSheetManager.styleSheet regularSystemFontOfSize:size];
}

+ (UIFont *)ml_boldSwizzledSystemFontOfSize:(CGFloat)size
{
	return [MLStyleSheetManager.styleSheet boldSystemFontOfSize:size];
}

+ (UIFont *)ml_regularSystemFontOfSize:(CGFloat)size
{
	return [MLStyleSheetManager.styleSheet regularSystemFontOfSize:size];
}

+ (UIFont *)ml_boldSystemFontOfSize:(CGFloat)size
{
	return [MLStyleSheetManager.styleSheet boldSystemFontOfSize:size];
}

+ (UIFont *)ml_thinSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet thinSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_lightSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet lightSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_mediumSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet mediumSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_semiboldSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet semiboldSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_extraboldSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet extraboldSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_blackSystemFontOfSize:(CGFloat)fontSize
{
	return [MLStyleSheetManager.styleSheet blackSystemFontOfSize:fontSize];
}

+ (UIFont *)ml_systemFontWithWeight:(CGFloat)weight size:(CGFloat)fontSize
{
	if (weight <= MLFontWeightThin) {
		return [UIFont ml_thinSystemFontOfSize:fontSize];
	} else if (weight <= MLFontWeightLight) {
		return [UIFont ml_lightSystemFontOfSize:fontSize];
	} else if (weight < MLFontWeightMedium) {
		return [UIFont ml_regularSystemFontOfSize:fontSize];
	} else if (weight < MLFontWeightSemibold) {
		return [UIFont ml_mediumSystemFontOfSize:fontSize];
	} else if (weight < MLFontWeightBold) {
		return [UIFont ml_semiboldSystemFontOfSize:fontSize];
	} else if (weight < MLFontWeightHeavy) {
		return [UIFont ml_boldSystemFontOfSize:fontSize];
	} else if (weight < MLFontWeightBlack) {
		return [UIFont ml_extraboldSystemFontOfSize:fontSize];
	} else {
		return [UIFont ml_blackSystemFontOfSize:fontSize];
	}
}

+ (UIFont *)ml_systemFontFromFont:(UIFont *)originalFont
{
	NSDictionary *traits = [originalFont.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];

	if (traits[UIFontWeightTrait]) {
		CGFloat weight = [traits[UIFontWeightTrait] floatValue];
		return [UIFont ml_systemFontWithWeight:weight size:originalFont.pointSize];
	} else {
		return [UIFont ml_regularSystemFontOfSize:originalFont.pointSize];
	}
}

@end
