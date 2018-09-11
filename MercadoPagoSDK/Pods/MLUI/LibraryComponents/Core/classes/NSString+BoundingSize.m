//
// NSString+BoundingRect.m
// MercadoLibre
//
// Created by Fabian Celdeiro on 10/14/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "NSString+BoundingSize.h"

@implementation NSString (BoundingSize)

- (CGSize)ml_boundingRectSizeWithSize:(CGSize)size andFont:(UIFont *)font
{
	CGSize textSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:font ? @{NSFontAttributeName : font} : nil context:nil].size;
	return textSize;
}

- (CGSize)ml_sizeWithFont:(UIFont *)font
{
	if (font) {
		return [self sizeWithAttributes:@{NSFontAttributeName : font}];
	} else {
	    return CGSizeZero;
	}
}

@end
