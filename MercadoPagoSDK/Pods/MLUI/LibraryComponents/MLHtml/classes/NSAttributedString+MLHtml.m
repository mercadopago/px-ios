//
// NSAttributedString+Html.m
// MercadoLibre
//
// Created by amargalef on 25/5/16.
// Copyright © 2016 MercadoLibre - Mobile Apps. All rights reserved.
//

#import "NSAttributedString+MLHtml.h"

@implementation NSAttributedString (MLHtml)

+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText error:(NSError *__autoreleasing *)error
{
	// forward the request to the helper, this way NSAttributedString is not populated with auxiliary methods
	return [MLHtml attributedStringWithHtml:htmlText attributes:nil error:error];
}

+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs error:(NSError *__autoreleasing *)error
{
	// forward the request to the helper, this way NSAttributedString is not populated with auxiliary methods
	return [MLHtml attributedStringWithHtml:htmlText attributes:attrs error:error];
}

+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText
                                 attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                              error:(NSError *__autoreleasing *)error
{
	return [MLHtml attributedStringWithHtml:htmlText attributesProvider:attributesProvider error:error];
}

+ (NSAttributedString *)ml_attributedStringWithHtml:(NSString *)htmlText
                                 attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                         attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs
                                              error:(NSError *__autoreleasing *)error
{
	return [MLHtml attributedStringWithHtml:htmlText attributesProvider:attributesProvider attributes:attrs error:error];
}

@end
