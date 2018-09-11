//
// UILabel+MLStyle.m
// MLUI
//
// Created by Julieta Puente on 7/25/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "UILabel+MLStyle.h"
#import "JRSwizzle.h"

@implementation UILabel (MLStyle)

+ (void)load
{
#ifdef MLUI_OVERRIDE_FONT
	SEL originalSetFont = @selector(setFont:);
	SEL swizzleSetFont = @selector(ml_swizzleSetFont:);
	[self jr_swizzleMethod:originalSetFont withMethod:swizzleSetFont error:nil];
	SEL originalSetText = @selector(setText:);
	SEL swizzleSetText = @selector(ml_swizzleSetText:);
	[self jr_swizzleMethod:originalSetText withMethod:swizzleSetText error:nil];
#else
	NSLog(@"Won't override system fonts with meli fonts - UILabel");
#endif
}

- (void)ml_setStyle:(MLStyle)style
{
	MLStyleUtils *styleUtils = [[MLStyleUtils alloc]init];
	NSDictionary *attrDictionary = [styleUtils attributedDictionaryForStyle:style];

	// Obtain attriburedString
	NSMutableAttributedString *attrString = [self attributedTextForAttributedDictionary:attrDictionary];

	// Add font to attributedText
	UIFont *attrFont = attrDictionary[NSFontAttributeName];
	// Verify if the font was set
	if (attrFont) {
		[attrString addAttribute:NSFontAttributeName value:attrDictionary[NSFontAttributeName] range:NSMakeRange(0, attrString.length)];
		self.font = attrFont;
	}

	self.attributedText = attrString;
}

#pragma mark - swizzle methods

- (void)ml_swizzleSetFont:(UIFont *)font
{
	// Call setFont
	[self ml_swizzleSetFont:font];

	// Apply style
	[self applyStyleForFont:font];
}

- (void)ml_swizzleSetText:(NSString *)text
{
	// Call setText
	[self ml_swizzleSetText:text];

	// Apply style
	[self applyStyleForFont:self.font];
}

- (void)applyStyleForFont:(UIFont *)font
{
	MLStyleUtils *style = [[MLStyleUtils alloc]init];
	NSDictionary *attrDictionary = [style attributedDictionaryForFont:font];

	// Obtain attriburedString
	NSMutableAttributedString *attrString = [self attributedTextForAttributedDictionary:attrDictionary];

	// Add font to attributedText
	if (font) {
		[attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrString.length)];
	}

	self.attributedText = attrString;
}

- (NSMutableAttributedString *)attributedTextForAttributedDictionary:(NSDictionary *)attrDictionary
{
	NSString *text = self.text;
	if (!text) {
		text = @"";
	}
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];

	NSMutableParagraphStyle *paragraphStyle = attrDictionary[NSParagraphStyleAttributeName];

	// Add label alignment to paragraphStyle if it is not the default one
	NSTextAlignment alignment = self.textAlignment;
	if (alignment != NSTextAlignmentNatural) {
		paragraphStyle.alignment = self.textAlignment;
	}

	// Add label line break mode to paragraphStyle if it is not the default one
	NSLineBreakMode lineBreakMode = self.lineBreakMode;
	if (lineBreakMode != NSLineBreakByWordWrapping) {
		paragraphStyle.lineBreakMode = lineBreakMode;
	}

	if ([self.attributedText length] > 0) {
		NSParagraphStyle *existingParagraphStyle = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
		if (existingParagraphStyle.lineSpacing) {
			paragraphStyle.lineSpacing = existingParagraphStyle.lineSpacing;
		}
	}

	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];

	return attributedString;
}

@end
