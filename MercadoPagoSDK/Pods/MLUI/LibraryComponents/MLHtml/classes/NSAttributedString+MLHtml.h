//
// NSAttributedString+Html.h
// MercadoLibre
//
// Created by amargalef on 25/5/16.
// Copyright © 2016 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "MLHtml.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (MLHtml)

/**
 *  Build an NSAttributedString from an html without default style (font, color).
 *
 *  @param htmlText html to render in NSAttributedString
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText error:(NSError *__autoreleasing *)error;

/**
 *  Build an NSAttributedString from an html with default style.
 *
 *  @param htmlText html to render in NSAttributedString
 *  @param attrs    Default configurations to be used when rendering the html
 *					Supports:
 *						- NSForegroundColorAttributeName: Value must be a UIColor*
 *						- NSFontAttributeName: Value must be a UIFont
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs error:(NSError *__autoreleasing *)error;

/**
 *  Build an NSAttributedString from an html with default style and process every tag with the attributesProvider.
 *
 *  @param htmlText				html to render in NSAttributedString
 *  @param attributesProvider	Protocol to process every tag if exists any not supported by default
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText
                                 attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                              error:(NSError *__autoreleasing *)error;

/**
 *  Build an NSAttributedString from an html with default style and process every tag with the attributesProvider.
 *
 *  @param htmlText				html to render in NSAttributedString
 *  @param attributesProvider	Protocol to process every tag if exists any not supported by default
 *  @param attrs    Default configurations to be used when rendering the html
 *					Supports:
 *						- NSForegroundColorAttributeName: Value must be a UIColor*
 *						- NSFontAttributeName: Value must be a UIFont
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText
                                 attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                         attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs
                                              error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
