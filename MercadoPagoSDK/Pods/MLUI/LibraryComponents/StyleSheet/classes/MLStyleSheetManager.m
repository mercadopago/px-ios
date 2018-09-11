//
// MLStyleSheetManager.m
// MercadoLibre
//
// Created by Cristian Leonel Gibert on 1/18/18.
//

#import "MLStyleSheetManager.h"

@implementation MLStyleSheetManager

static id <MLStyleSheetProtocol> _styleSheet;

+ (id <MLStyleSheetProtocol>)styleSheet
{
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		if (_styleSheet == nil) {
		    _styleSheet = [MLStyleSheetDefault new];
		}
	});
	return _styleSheet;
}

+ (void)setStyleSheet:(id <MLStyleSheetProtocol>)styleSheet
{
	NSAssert(styleSheet, @"The styleSheet must not be nil");
	_styleSheet = styleSheet;
}

@end
