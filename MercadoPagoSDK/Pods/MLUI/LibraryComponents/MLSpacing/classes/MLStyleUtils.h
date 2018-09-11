//
// MLStyleUtils.h
// MLUI
//
// Created by Julieta Puente on 7/21/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLStyle.h"

@interface MLStyleUtils : NSObject

/**
 *  Creates a dictionary containing the NSFontAttributeName and  NSParagraphStyleAttributeName for the style
 *
 *  @param style     style
 */
- (NSDictionary *)attributedDictionaryForStyle:(MLStyle)style;

/**
 *  Creates a dictionary containing the NSParagraphStyleAttributeName for the font
 *
 *  @param font     label or textView font
 */
- (NSDictionary *)attributedDictionaryForFont:(UIFont *)font;

@end
