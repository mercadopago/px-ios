//
// MLButton.h
// MLUI
//
// Created by Julieta Puente on 13/1/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MLButtonConfig;

typedef NS_ENUM (NSInteger, MLButtonStyle) {
	MLButtonStylePrimaryAction = 0,
	MLButtonStyleSecondaryAction,
	MLButtonStylePrimaryOption,
	MLButtonStyleSecondaryOption
};

@interface MLButton : UIControl

///---------------------
/// @name Properties
///---------------------

/**
 *  Button title
 */
@property (nonatomic, copy, nullable) NSString *buttonTitle;

/**
 *  Button config.
 *
 *  Set this property to automatically change the current config.
 */
@property (nonatomic, strong) MLButtonConfig *config;

/**
 *  Button default style, override this property
 *	to automatically change the current style
 */
@property (nonatomic, assign) MLButtonStyle style DEPRECATED_MSG_ATTRIBUTE("We recommend using the config property instead.");

///---------------------
/// @name Initializers
///---------------------

/**
 *  Creates a new button with the selected style
 *
 *  @param config  set of styles for the differents states
 */
- (instancetype)initWithConfig:(MLButtonConfig *)config;

/**
 *  Other deprecated initializers
 */
- (instancetype)initWithStyle:(MLButtonStyle)style __attribute__((deprecated("We recommend start using the initWithConfig: instead.")));

- (instancetype)init;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

///----------------------
/// @name Custom Methods
///----------------------

/**
 *  Update the button states manually.
 *
 *  It is equivalent to set config property.
 */
- (void)updateStatesConfig:(MLButtonConfig *)config;

/**
 *  Setup the loading state
 */
- (void)showLoadingStyle;
- (void)hideLoadingStyle;

@end

NS_ASSUME_NONNULL_END
