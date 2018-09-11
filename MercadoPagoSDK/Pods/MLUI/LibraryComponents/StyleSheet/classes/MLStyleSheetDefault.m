//
// MLStyleSheetDefault.m
// MercadoLibre
//
// Created by Cristian Leonel Gibert on 1/18/18.
//

#import "MLStyleSheetDefault.h"

@implementation MLStyleSheetDefault

#pragma mark Colors
- (UIColor *)primaryColor
{
	return [UIColor colorWithRed:1.00 green:0.86 blue:0.08 alpha:1.0];
}

- (UIColor *)lightPrimaryColor
{
	return [UIColor colorWithRed:1.00 green:0.92 blue:0.47 alpha:1.0];
}

- (UIColor *)secondaryColor
{
	return [UIColor colorWithRed:0.20 green:0.51 blue:0.98 alpha:1.0];
}

- (UIColor *)secondaryColorPressed
{
	return [UIColor colorWithRed:0.15 green:0.38 blue:0.73 alpha:1.0];
}

- (UIColor *)secondaryColorDisabled
{
	return [UIColor colorWithRed:0.84 green:0.90 blue:1.00 alpha:1.0];
}

- (UIColor *)successColor
{
	return [UIColor colorWithRed:0.22 green:0.71 blue:0.29 alpha:1.0];
}

- (UIColor *)warningColor
{
	return [UIColor colorWithRed:0.98 green:0.67 blue:0.38 alpha:1.0];
}

- (UIColor *)errorColor
{
	return [UIColor colorWithRed:0.94 green:0.27 blue:0.29 alpha:1.0];
}

- (UIColor *)blackColor
{
	return [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
}

- (UIColor *)darkGreyColor
{
	return [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
}

- (UIColor *)greyColor
{
	return [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
}

- (UIColor *)midGreyColor
{
	return [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
}

- (UIColor *)lightGreyColor
{
	return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
}

- (UIColor *)whiteColor
{
	return [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
}

- (UIColor *)modalBackgroundColor
{
	return [UIColor colorWithRed:1.00 green:0.86 blue:0.08 alpha:1.0];
}

- (UIColor *)modalTintColor
{
	return [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
}

#pragma mark Fonts
- (UIFont *)regularSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
}

- (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
}

- (UIFont *)thinSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightThin];
}

- (UIFont *)lightSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

- (UIFont *)mediumSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
}

- (UIFont *)semiboldSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
}

- (UIFont *)extraboldSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightHeavy];
}

- (UIFont *)blackSystemFontOfSize:(CGFloat)fontSize
{
	return [UIFont systemFontOfSize:fontSize weight:UIFontWeightBlack];
}

@end
