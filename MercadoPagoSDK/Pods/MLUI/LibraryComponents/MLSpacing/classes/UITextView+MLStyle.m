//
// UITextView+MLStyle.m
// MLUI
//
// Created by Julieta Puente on 7/25/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "UITextView+MLStyle.h"
#import "JRSwizzle.h"

@implementation UITextView (MLStyle)

+ (void)load
{
#ifdef MLUI_OVERRIDE_FONT
	SEL originalSetFont = @selector(setFont:);
	SEL swizzleSetFont = @selector(ml_swizzleTextViewSetFont:);
	[self jr_swizzleMethod:originalSetFont withMethod:swizzleSetFont error:nil];
#else
	NSLog(@"Won't override system fonts with meli fonts - UITextView");
#endif
}

- (void)ml_setStyle:(MLStyle)style
{
	MLStyleUtils *styleU = [[MLStyleUtils alloc]init];
	NSDictionary *attrDictionary = [styleU attributedDictionaryForStyle:style];
	self.typingAttributes = attrDictionary;
}

- (void)ml_swizzleTextViewSetFont:(UIFont *)font
{
	// Call setFont
	[self ml_swizzleTextViewSetFont:font];

	// Apply style
	MLStyleUtils *style = [[MLStyleUtils alloc]init];
	NSDictionary *attrDictionary = [style attributedDictionaryForFont:font];

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:attrDictionary];
	[dict setObject:font forKey:NSFontAttributeName];
	self.typingAttributes = dict;
}

@end
