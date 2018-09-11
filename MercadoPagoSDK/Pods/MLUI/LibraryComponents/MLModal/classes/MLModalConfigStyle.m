//
// MLModalConfigStyle.m
// Pods
//
// Created by Jonatan Urquiza on 9/12/17.
//
//

#import "MLModalConfigStyle.h"
#import "MLStyleSheetManager.h"
#import "UIFont+MLFonts.h"

@implementation MLModalConfigStyle

- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
                  headerBackgroundColor:(UIColor *)headerBackgroundColor
                              tintColor:(UIColor *)tintColor
                             titleColor:(UIColor *)titleColor
                              titleFont:(UIFont *)titleFont
                           showBlurView:(BOOL)showBlurView
{
	if (self = [super init]) {
		NSAssert(backgroundColor, @"backgroundColor is mandatory");
		NSAssert(headerBackgroundColor, @"headerBackgroundColor is mandatory");
		NSAssert(tintColor, @"tintColor is mandatory");
		NSAssert(titleColor, @"titleColor is mandatory");
		NSAssert(titleFont, @"titleFont is mandatory");
		_backgroundColor = backgroundColor;
		_headerBackgroundColor = headerBackgroundColor;
		_tintColor = tintColor;
		_titleColor = titleColor;
		_titleFont = titleFont;
		_showBlurView = showBlurView;
	}
	return self;
}

- (instancetype)init
{
	if (self = [super init]) {
		_backgroundColor = [MLStyleSheetManager.styleSheet.modalBackgroundColor colorWithAlphaComponent:0.8];
		_headerBackgroundColor = MLStyleSheetManager.styleSheet.lightGreyColor;
		_tintColor = MLStyleSheetManager.styleSheet.modalTintColor;
		_titleColor = MLStyleSheetManager.styleSheet.blackColor;
		_titleFont = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeLarge];
		_showBlurView = YES;
	}
	return self;
}

@end
