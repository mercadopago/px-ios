//
// MLTextFieldWithLabel.h
// MLUI
//
// Created by Juan Andres Gebhard on 5/5/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * States of the MLTitledSingleLineTextField
 */
typedef NS_ENUM (NSInteger, MLTitledTextFieldState) {
	MLTitledTextFieldStateNormal,
	MLTitledTextFieldStateEditing,
	MLTitledTextFieldStateError,
	MLTitledTextFieldStateDisabled
};

@class MLTitledSingleLineTextField;

/**
 * The UITextFieldDelegate protocol defines methods that you use to manage the editing and
 * validation of text in a MLTextFieldWithLabel object. All of the methods of this protocol are optional.
 */
@protocol MLTitledTextFieldDelegate <NSObject>

@optional

/**
 * Asks the delegate if editing should begin in the specified text field.
 * @param textField The text field in which editing is about to begin.
 * @return YES if editing should begin or NO if it should not.
 */
- (BOOL)textFieldShouldBeginEditing:(MLTitledSingleLineTextField *)textField;

/**
 * Tells the delegate that editing began in the specified text field.
 * @param textField The text field in which an editing session began.
 */
- (void)textFieldDidBeginEditing:(MLTitledSingleLineTextField *)textField;

/**
 * Asks the delegate if editing should stop in the specified text field.
 * @param textField The text field in which editing is about to end.
 * @return YES if editing should stop or NO if it should continue.
 */
- (BOOL)textFieldShouldEndEditing:(MLTitledSingleLineTextField *)textField;

/**
 *  Tells the delegate that editing stopped for the specified text field.
 * @param textField The text field for which editing ended.
 */
- (void)textFieldDidEndEditing:(MLTitledSingleLineTextField *)textField;

/**
 * Asks the delegate if the specified text should be changed.
 * @param textField The text field containing the text.
 * @param range The range of characters to be replaced.
 * @param string  The replacement string for the specified range. During typing, this parameter normally
 * contains only the single new character that was typed, but it may contain more characters if the user
 * is pasting text. When the user deletes one or more characters, the replacement string is empty.
 * @return YES if the specified text range should be replaced; otherwise, NO to keep the old text.
 */
- (BOOL)    textField:(MLTitledSingleLineTextField *)textField shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string;

/**
 * Asks the delegate if the text field should process the pressing of the return button.
 * @param textField The text field whose return button was pressed.
 * @return YES if the text field should implement its default behavior for the return button; otherwise, NO.
 */
- (BOOL)textFieldShouldReturn:(MLTitledSingleLineTextField *)textField;

@end

/**
 * Text field with a title.
 */
@interface MLTitledSingleLineTextField : UIControl

/**
 * The text content of the text field.
 */
@property (nonatomic, copy, nullable) IBInspectable NSString *text;

/**
 * The name of the field. This string is displayed in the label.
 */
@property (nonatomic, copy, nullable) IBInspectable NSString *title;

/**
 * The textfield placeholder.
 */
@property (nonatomic, copy, nullable) IBInspectable NSString *placeholder;

/**
 * An error string to be displayed.
 */
@property (nonatomic, copy, nullable) IBInspectable NSString *errorDescription;

/**
 * An helper description text to show below the textfield.
 */
@property (nonatomic, copy, nullable) NSString *helperDescription;

/**
 * The maximum number of characters of the textfield.
 */
@property (nonatomic, assign) IBInspectable NSUInteger maxCharacters;

/**
 * Whether this component should display a label with the number of characters in the text property.
 * The default value for this property is NO.
 */
@property (nonatomic, assign, getter = isCharactersCountVisible) IBInspectable BOOL charactersCountVisible;

/**
 * The text field delegate.
 */
@property (nonatomic, weak, nullable) IBOutlet id <MLTitledTextFieldDelegate> delegate;

/**
 * The textfield state.
 */
@property (nonatomic, assign, readonly) MLTitledTextFieldState state;

/**
 * An accessory view that will be placed on the right of the control.
 */
@property (strong, nonatomic, nullable) IBOutlet UIView *accessoryView;

/**
 * Textfield keyboard type.
 * Default is UIKeyboardTypeDefault
 */
@property (nonatomic) UIKeyboardType keyboardType;

/**
 * The Autocapitalization type.
 * Default is UITextAutocapitalizationTypeSentences
 */
@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;

/**
 * The Autocorrection type.
 * Default is UITextAutocorrectionTypeDefault
 */
@property (nonatomic) UITextAutocorrectionType autocorrectionType;

/**
 * Identifies whether the text object should disable text copying and in some cases hide the text being entered.
 * Default is NO.
 */
@property (nonatomic) BOOL secureTextEntry;

/**
 * Use this method to specify the component text aligment inside the textField
 */
- (void)setupInnerTextWithAlignment:(NSTextAlignment)textAlignment;

/**
 * Applies the fonts and colors to the controls of this components.
 * You should not call this method directly, but subclasses may reimplement it for custom styling.
 */
- (void)style;

/**
 * Returns a text input control such as an instance of UITextField or UITextView.
 * This method should not be called directly. You should use it when subclassing in order to
 * define the control to be used as text input.
 * @return a text input control to be used by this component.
 */
- (UIView <UITextInputTraits, UITextInput> *)textInputControl;

@end

NS_ASSUME_NONNULL_END
