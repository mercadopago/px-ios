//
// UILabel+MLFonts.m
// MLUI
//
// Created by Nicolas Andres Suarez on 27/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "UILabel+MLFonts.h"
#import "UIFont+MLFonts.h"
#import "NSAttributedString+MLFonts.h"

@implementation UILabel (MLFonts)

- (void)ml_shouldSetSystemFont:(NSInteger)should
{
	if (!should || !self.font) {
		return;
	}

	if (self.attributedText) {
		self.attributedText = [self.attributedText ml_attributedStringByReplacingFontWithSystemFont];
	} else {
		self.font = [UIFont ml_systemFontFromFont:self.font];
	}
}

@end
