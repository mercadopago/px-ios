//
// UIFont+MLFonts.h
// MLUI
//
// Created by Julieta Puente on 12/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (MLFonts)

extern const int kMLFontsSizeXXLarge;
extern const int kMLFontsSizeXLarge;
extern const int kMLFontsSizeLarge;
extern const int kMLFontsSizeMedium;
extern const int kMLFontsSizeSmall;
extern const int kMLFontsSizeXSmall;
extern const int kMLFontsSizeXXSmall;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in regular weight in the specified size.
 *  This method is swizzled with system's systemFontOfSize: so it could be used with the same result.
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_regularSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in bold weight in the specified size.
 *  This method is swizzled with system's boldSystemFontOfSize so it could be used with the same result.
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_boldSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in thin weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_thinSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in light weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_lightSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in medium weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_mediumSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in semibold weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_semiboldSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in heavy weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_extraboldSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the font object used for standard interface items that are rendered
 *  in black weight in the specified size.
 *
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 */
+ (UIFont *)ml_blackSystemFontOfSize:(CGFloat)fontSize;

/**
 *  Returns the system font by weight and size
 *
 *  @param weight   The weight of the font. The valid value range is from -1.0 to 1.0. The value of 0.0 corresponds to the regular
 *  @param fontSize The size (in points) to which the font is scaled. This value must be greater than 0.0.
 *
 */
+ (UIFont *)ml_systemFontWithWeight:(CGFloat)weight size:(CGFloat)fontSize;

/**
 *  Creates an instance of UIFont, with the size and weight of `originalFont`.
 *
 *  @param originalFont Font which takes the size and weight.
 *
 *  @return Instance of UIFont.
 */
+ (UIFont *)ml_systemFontFromFont:(UIFont *)originalFont;

@end
