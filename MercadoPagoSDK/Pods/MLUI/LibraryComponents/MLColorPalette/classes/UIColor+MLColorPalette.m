//
// UIColor+MLColorPalette.m
// MLUI
//
// Created by Julieta Puente on 11/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "UIColor+MLColorPalette.h"

@implementation UIColor (MLColorPalette)

+ (UIColor *)ml_meli_yellow
{
	return [UIColor colorWithRed:255.f / 255.f green:219.f / 255.f blue:21.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_light_yellow
{
	return [UIColor colorWithRed:255.f / 255.f green:234.f / 255.f blue:120.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_black
{
	return [UIColor colorWithRed:51.f / 255.f green:51.f / 255.f blue:51.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_dark_grey
{
	return [UIColor colorWithRed:102.f / 255.f green:102.f / 255.f blue:102.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_grey
{
	return [UIColor colorWithRed:153.f / 255.f green:153.f / 255.f blue:153.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_mid_grey
{
	return [UIColor colorWithRed:204.f / 255.f green:204.f / 255.f blue:204.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_light_grey
{
	return [UIColor colorWithRed:238.f / 255.f green:238.f / 255.f blue:238.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_white
{
	return [UIColor colorWithRed:255.f / 255.f green:255.f / 255.f blue:255.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_blue
{
	return [UIColor colorWithRed:52.f / 255.f green:131.f / 255.f blue:250.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_green
{
	return [UIColor colorWithRed:57.f / 255.f green:181.f / 255.f blue:74.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_orange
{
	return [UIColor colorWithRed:0.98 green:0.67 blue:0.38 alpha:1.0];
}

+ (UIColor *)ml_meli_red
{
	return [UIColor colorWithRed:240.f / 255.f green:68.f / 255.f blue:73.f / 255.f alpha:1];
}

+ (UIColor *)ml_meli_error
{
	return [UIColor ml_meli_red];
}

+ (UIColor *)ml_meli_success
{
	return [UIColor ml_meli_green];
}

+ (UIColor *)ml_meli_background
{
	return [UIColor ml_meli_light_grey];
}

@end
