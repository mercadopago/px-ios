//
// UIColor+MercadoLibre.m
// MercadoLibre
//
// Created by Fabian Celdeiro on 8/22/12.
// Copyright (c) 2012 Casa. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (MercadoLibre)

+ (UIColor *)ml_textFeedbackColor
{
	return [UIColor colorWithRed:49.f / 255.f green:113.f / 255.f blue:159.f / 255.f alpha:1];
}

+ (UIColor *)ml_textDefaultColor
{
	return [UIColor colorWithRed:84.0 / 255.0 green:84.0 / 255.0 blue:84.0 / 255.0 alpha:1.0];
}

+ (UIColor *)ml_textSubtitleColor
{
	return [UIColor colorWithRed:0.0 green:102.0 / 255.0 blue:255.0 alpha:1.0];
}

+ (UIColor *)ml_backgroundDefaultColor;
{
	return [UIColor groupTableViewBackgroundColor];
}

+ (UIColor *)ml_cellBackgroundDefaultColor
{
	return [UIColor whiteColor];
}

+ (UIColor *)ml_tableViewBackgroundDefaultColor
{
	return [UIColor whiteColor];
}

+ (UIColor *)ml_bigErrorBackgroundDefaultColor
{
	return [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1.0];
}

+ (UIColor *)ml_priceColor
{
	return [UIColor colorWithRed:168.f / 255.f green:40.f / 255.f blue:41.f / 255.f alpha:1];
}

+ (UIColor *)ml_mercadoLibreLightBlueColor
{
	return [UIColor colorWithRed:233.f / 255.f green:238.f / 255.f blue:253.f / 255.f alpha:1];
}

+ (UIColor *)ml_mercadoLibreBlueColor
{
	return [UIColor colorWithRed:43.f / 255.f green:50.f / 255.f blue:116.f / 255.f alpha:1];
}

+ (UIColor *)ml_errorCellColor
{
	return [UIColor colorWithRed:179.f / 255.f green:76.f / 255.f blue:66.f / 255.f alpha:1];
}

+ (UIColor *)ml_warningCellColor
{
	return [UIColor colorWithRed:170.f / 255.f green:133.f / 255.f blue:71.f / 255.f alpha:1];
}

+ (UIColor *)ml_tableViewMisComprasBackgroundColor
{
	return [UIColor colorWithRed:236.f / 255.f green:231.f / 255.f blue:227.f / 255.f alpha:1];
}

+ (UIColor *)ml_tableViewMisComprasFooterBackgroundColor
{
	return [UIColor colorWithRed:247.f / 255.f green:245.f / 255.f blue:244.f / 255.f alpha:1];
}

+ (UIColor *)ml_navigationBarColor
{
	return [UIColor colorWithRed:254.f / 255.f green:220.f / 255.f blue:19.f / 255.f alpha:1];
}

+ (UIColor *)ml_textNavigationBarColor
{
	return [UIColor colorWithRed:51.f / 255.f green:51.f / 255.f blue:51.f / 255.f alpha:1.0f];
}

+ (UIColor *)ml_listingsDetailLine
{
	return [UIColor colorWithRed:200.f / 255.f green:199.f / 255.f blue:206.f / 255.f alpha:1.0f];
}

+ (UIColor *)ml_iOS7TableViewBackgroundColor
{
	return [UIColor colorWithRed:243.f / 255.f green:243.f / 255.f blue:243.f / 255.f alpha:1.0f];
}

+ (UIColor *)ml_tabBarColor
{
	return [UIColor colorWithRed:128.f / 255.f green:128.f / 255.f blue:128.f / 255.f alpha:1];
}

+ (UIColor *)ml_titleColor
{
	return [UIColor colorWithRed:51.f / 255.f green:51.f / 255.f blue:51.f / 255.f alpha:1];
}

- (UIColor *)ml_lighterColor
{
	CGFloat h, s, b, a;
	if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		return [UIColor colorWithHue:h
		                  saturation:s
		                  brightness:MIN(b * 1.3, 1.0)
		                       alpha:a];
	}
	return nil;
}

- (UIColor *)ml_darkerColor
{
	CGFloat h, s, b, a;
	if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		return [UIColor colorWithHue:h
		                  saturation:s
		                  brightness:b * 0.75
		                       alpha:a];
	}
	return nil;
}

+ (UIColor *)ml_defaultPriceColor
{
	return [UIColor colorWithRed:51.f / 255.f green:51.f / 255.f blue:51.f / 255.f alpha:1];
}

+ (UIColor *)ml_disabledPriceColor
{
	return [UIColor colorWithRed:178.f / 255.f green:178.f / 255.f blue:178.f / 255.f alpha:1];
}

+ (UIColor *)ml_discountPriceColor
{
	return [UIColor colorWithRed:178.f / 255.f green:178.f / 255.f blue:178.f / 255.f alpha:1];
}

@end
