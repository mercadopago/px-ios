//
// NSString+BoundingRect.h
// MercadoLibre
//
// Created by Fabian Celdeiro on 10/14/14.
// Copyright (c) 2014 MercadoLibre - Mobile Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  Added methods to calculate the size of a string. Used commonly on labels
 */
@interface NSString (BoundingSize)

/*!
 *  @brief  Given a CGSize and a UIFont, calculates the height needed to display the whole text
 *
 *  @param size A normal CGSize
 *  @param font Any UIFont
 *
 *  @return CGSize: Width is the origin 'size' width and the height is the minimum needed to display the whole text
 */
- (CGSize)ml_boundingRectSizeWithSize:(CGSize)size andFont:(UIFont *)font;

/*!
 *  @brief  Given a UIFont, calculates the height needed to display the whole text
 *
 *  @param font Any UIFont
 *
 *  @return A size with a normal width (320 normally) and the height is the minimum needed to display the whole text
 */
- (CGSize)ml_sizeWithFont:(UIFont *)font;

@end
