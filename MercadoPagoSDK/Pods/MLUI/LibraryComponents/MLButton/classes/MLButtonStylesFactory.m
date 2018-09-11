//
// MLButtonStylesFactory.m
// Pods
//
// Created by Cristian Leonel Gibert on 1/31/17.
//
//

#import "MLButtonStylesFactory.h"
#import "MLButtonConfig.h"
#import "MLButtonConfigStyle.h"
#import "MLStyleSheetManager.h"

@implementation MLButtonStylesFactory

+ (MLButtonConfig *)configForButtonType:(MLButtonType)buttonType
{
	return [self setupStyleForButton:buttonType];
}

+ (MLButtonConfig *)setupStyleForButton:(MLButtonType)buttonType
{
	MLButtonConfig *buttonStates = [[MLButtonConfig alloc] init];

	switch (buttonType) {
		case MLButtonTypePrimaryAction: {
			buttonStates.defaultState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.whiteColor
			                                                              backgroundColor:MLStyleSheetManager.styleSheet.secondaryColor
			                                                                  borderColor:MLStyleSheetManager.styleSheet.secondaryColor];
			buttonStates.highlightedState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.whiteColor
			                                                                  backgroundColor:MLStyleSheetManager.styleSheet.secondaryColorPressed
			                                                                      borderColor:MLStyleSheetManager.styleSheet.secondaryColorPressed];
			buttonStates.disableState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.whiteColor
			                                                              backgroundColor:MLStyleSheetManager.styleSheet.secondaryColorDisabled
			                                                                  borderColor:MLStyleSheetManager.styleSheet.secondaryColorDisabled];
			break;
		}

		case MLButtonTypeSecondaryAction: {
			buttonStates.defaultState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColor
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:MLStyleSheetManager.styleSheet.secondaryColor];
			buttonStates.highlightedState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColorPressed
			                                                                  backgroundColor:MLStyleSheetManager.styleSheet.midGreyColor
			                                                                      borderColor:MLStyleSheetManager.styleSheet.secondaryColorPressed];
			buttonStates.disableState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColorDisabled
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:MLStyleSheetManager.styleSheet.secondaryColorDisabled];
			break;
		}

		case MLButtonTypePrimaryOption: {
			buttonStates.defaultState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColor
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:UIColor.clearColor];
			buttonStates.highlightedState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColorPressed
			                                                                  backgroundColor:MLStyleSheetManager.styleSheet.midGreyColor
			                                                                      borderColor:UIColor.clearColor];
			buttonStates.disableState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.secondaryColorDisabled
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:UIColor.clearColor];
			break;
		}

		case MLButtonTypeSecondaryOption: {
			buttonStates.defaultState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.greyColor
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:UIColor.clearColor];
			buttonStates.highlightedState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.greyColor
			                                                                  backgroundColor:[MLStyleSheetManager.styleSheet.blackColor colorWithAlphaComponent:0.1]
			                                                                      borderColor:UIColor.clearColor];
			buttonStates.disableState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.lightGreyColor
			                                                              backgroundColor:UIColor.clearColor
			                                                                  borderColor:UIColor.clearColor];
			break;
		}

		case MLButtonTypeLoading: {
			buttonStates.loadingState = [[MLButtonConfigStyle alloc] initWithContentColor:MLStyleSheetManager.styleSheet.whiteColor
			                                                              backgroundColor:MLStyleSheetManager.styleSheet.secondaryColor
			                                                                  borderColor:MLStyleSheetManager.styleSheet.secondaryColor];
			break;
		}
	}
	return buttonStates;
}

@end
