//
// MLStyleUtils.m
// MLUI
//
// Created by Julieta Puente on 7/21/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLStyleUtils.h"
#import "UIFont+MLFonts.h"

@interface MLStyleUtils ()
@property (nonatomic, assign) CGFloat lineSpacing;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSDictionary *styleDictionary;
@end

@implementation MLStyleUtils

- (NSDictionary *)attributedDictionaryForFont:(UIFont *)font
{
	self.lineSpacing = font.pointSize >= kMLFontsSizeLarge ? 4 : 2;
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = self.lineSpacing;

	NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
	[attrDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

	return attrDict;
}

- (NSDictionary *)attributedDictionaryForStyle:(MLStyle)style
{
	switch (style) {
		case MLStyleRegularXXLarge: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXXLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleRegularXLarge: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleRegularLarge: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleRegularMedium: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeMedium];
			self.lineSpacing = 2;
			break;
		}

		case MLStyleRegularSmall: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeSmall];
			self.lineSpacing = 2;
			break;
		}

		case MLStyleRegularXSmall: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXSmall];
			self.lineSpacing = 2;
			break;
		}

		case MLStyleRegularXXSmall: {
			self.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXXSmall];
			self.lineSpacing = 2;
			break;
		}

		case MLStyleLightXXLarge: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeXXLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightXLarge: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeXLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightLarge: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeLarge];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightMedium: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeMedium];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightSmall: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeSmall];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightXSmall: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeXSmall];
			self.lineSpacing = 4;
			break;
		}

		case MLStyleLightXXSmall: {
			self.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeXXSmall];
			self.lineSpacing = 2;
			break;
		}

		case MLStyleNone: {
			self.lineSpacing = 2;
			break;
		}

		default: {
			self.lineSpacing = 2;
			break;
		}
	}

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = self.lineSpacing;

	NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
	[attrDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
	if (self.font) {
		[attrDict setObject:self.font forKey:NSFontAttributeName];
	}
	return attrDict;
}

@end
