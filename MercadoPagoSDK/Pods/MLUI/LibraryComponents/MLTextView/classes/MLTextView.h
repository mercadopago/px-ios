//
// MLTextView.h
// MLUI
//
// Created by MAURO CARREÑO on 5/17/17.
// Copyright © 2017 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLTextViewPlaceholder : UILabel

@end

@interface MLTextView : UIControl

/**
 * The real textview. Should be used with extra caution and only when necessary.
 */
@property (nonatomic, weak, readonly) UITextView *_Nullable textView;

/**
 * The real placeholder (UILabel). Should be used with extra caution and only when necessary.
 */
@property (nonatomic, weak, readonly) MLTextViewPlaceholder *_Nullable textViewPlaceholder;

/**
 * The text content of the text field.
 * The text should be changed from here to make it work as expected.
 */
@property (nonatomic, copy) NSString *_Nullable text;

/**
 * The textview placeholder's text.
 * The text should be changed from here to make it work as expected.
 */
@property (nonatomic, copy) IBInspectable NSString *_Nullable placeholder;

/**
 * The minimum amount of lines (default = 1).
 */
@property (nonatomic, assign) IBInspectable NSUInteger minLines;

/**
 * The maximum amount of lines (default = 1).
 */
@property (nonatomic, assign) IBInspectable NSUInteger maxLines;

/**
 * Whether the textview should shrink in size only to the minimum (default = true).
 */
@property (nonatomic, assign) IBInspectable BOOL flexibleSize;

/**
 * When the font is changed, the number of lines or something related to the internal textview, its recommended to call this method to force an internal update.
 */
- (void)styleHasChanged;

@end
