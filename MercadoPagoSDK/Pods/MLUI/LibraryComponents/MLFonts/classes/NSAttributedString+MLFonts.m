//
// NSAttributedString+MLFonts.m
// MLUI
//
// Created by Nicolas Andres Suarez on 5/4/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "NSAttributedString+MLFonts.h"
#import "UIFont+MLFonts.h"

@implementation NSAttributedString (MLFonts)

- (NSAttributedString *)ml_attributedStringByReplacingFontWithSystemFont
{
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
	[attributedString enumerateAttribute:NSFontAttributeName
	                             inRange:NSMakeRange(0, attributedString.length)
	                             options:0
	                          usingBlock: ^(id _Nullable value, NSRange range, BOOL *_Nonnull stop) {
	    if (value) {
	        UIFont *systemFont = [UIFont ml_systemFontFromFont:value];
	        if (![systemFont isEqual:value]) {
	            [attributedString removeAttribute:NSFontAttributeName range:range];
	            [attributedString addAttribute:NSFontAttributeName value:systemFont range:range];
			}
		}
	}];
	return attributedString;
}

@end
