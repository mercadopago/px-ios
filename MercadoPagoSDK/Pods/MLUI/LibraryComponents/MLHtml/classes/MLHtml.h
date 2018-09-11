//
// NSAttributedStringMLHtmlHelper.h
// MLUI
//
// Created by amargalef on 6/7/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 + *  Protocol to be used as an extension point for processing non html tags
 + */
@protocol MLHtmlAttributeProvider <NSObject>

@optional

/**
 *  Overrides any value from attrs if necesary, for example to support non html tags
 */
- (void)processAttributesForTag:(NSString *)tag attributes:(NSMutableDictionary <NSAttributedStringKey, id> *)attrs;

@end

/**
 *  Helper class for category 'NSAttributedString+MLHtml'.
 *  This way NSAttributedString is only populated with the NSAttributedString+MLHtml.h functions
 */
@interface MLHtml : NSObject

/**
 *  Build an NSAttributedString from an html without default style (font, color).
 *
 *  @param htmlText html to render in NSAttributedString
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText error:(NSError *__autoreleasing *)error;

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
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs error:(NSError *__autoreleasing *)error;

/**
 *  Build an NSAttributedString from an html with default style and process every tag with the attributesProvider.
 *
 *  @param htmlText				html to render in NSAttributedString
 *  @param attributesProvider	Protocol to process every tag if exists any not supported by default
 *
 *  @return NSAttributedString with html
 */
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText
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
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText
                              attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                      attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs
                                           error:(NSError *__autoreleasing *)error;
@end

NS_ASSUME_NONNULL_END
