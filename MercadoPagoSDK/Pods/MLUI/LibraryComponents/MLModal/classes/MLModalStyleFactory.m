//
// MLModalStyleFactory.m
// Pods
//
// Created by Jonatan Urquiza on 9/12/17.
//
//

#import "MLModalStyleFactory.h"
#import "MLModalConfigStyle.h"
#import "MLStyleSheetManager.h"
#import "UIFont+MLFonts.h"

@implementation MLModalStyleFactory

+ (MLModalConfigStyle *)configForModalType:(MLModalType)modalType
{
	MLModalConfigStyle *style;
	switch (modalType) {
		case MLModalTypeML:
		case MLModalTypeMP: {
			style = [[MLModalConfigStyle alloc] initWithBackgroundColor:MLStyleSheetManager.styleSheet.modalBackgroundColor
			                                      headerBackgroundColor:MLStyleSheetManager.styleSheet.lightGreyColor
			                                                  tintColor:MLStyleSheetManager.styleSheet.modalTintColor
			                                                 titleColor:MLStyleSheetManager.styleSheet.blackColor
			                                                  titleFont:[UIFont ml_lightSystemFontOfSize:kMLFontsSizeLarge] showBlurView:YES];
			break;
		}
	}
	return style;
}

@end
