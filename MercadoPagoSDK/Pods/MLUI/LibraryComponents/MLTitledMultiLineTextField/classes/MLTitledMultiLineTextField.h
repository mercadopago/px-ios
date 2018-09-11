//
// MLTitledMultiLineTextField.h
// MLUI
//
// Created by Juan Andres Gebhard on 5/17/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLTitledSingleLineTextField.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Multiline text field with a title.
 */
@interface MLTitledMultiLineTextField : MLTitledSingleLineTextField

/**
 * Maximum number of lines the text field can contain.
 * Once the number of lines has been reached, the user can no longer add text.
 */
@property (nonatomic, assign) IBInspectable NSUInteger maxLines;

/**
 * Enables the text vertical scrolling when the number of lines needed to render the text
 * are greater than the maxLines property.
 */
@property (nonatomic, assign, getter = isScrollEnabled) IBInspectable BOOL scrollEnabled;

/**
 * Identifies whether the text object should disable text copying and in some cases hide the text being entered.
 * Default is NO.
 */
@property (nonatomic) BOOL secureTextEntry NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
