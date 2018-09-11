//
// NSAttributedString+MLFonts.h
// MLUI
//
// Created by Nicolas Andres Suarez on 5/4/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (MLFonts)

/**
 *  Creates an instance of NSAttributedString replacing the font by system font (Proxima-Nova)
 *
 *  @return An instance of NSAttributedString
 */
- (NSAttributedString *)ml_attributedStringByReplacingFontWithSystemFont;

@end
