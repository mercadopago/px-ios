//
// MLSpinner.h
// MLUI
//
// Created by Julieta Puente on 18/4/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSpinnerConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, MLSpinnerStyle) {
	MLSpinnerStyleBlueBig,
	MLSpinnerStyleWhiteBig,
	MLSpinnerStyleBlueSmall,
	MLSpinnerStyleWhiteSmall
};

@interface MLSpinner : UIView

@property (nonatomic, readonly) BOOL isHidden;

/**
 *  Creates a spinner with the selected style
 *
 *  @param style     spinner style
 */
- (id)initWithStyle:(MLSpinnerStyle)style __attribute__((deprecated("We recommend start using the initWithConfig:text: instead.")));

/**
 *  Creates a spinner with the selected style and text
 *
 *  @param style     spinner style
 *  @param text      spinner text
 */
- (id)initWithStyle:(MLSpinnerStyle)style text:(nullable NSString *)text __attribute__((deprecated("We recommend start using the initWithConfig:text: instead.")));

/**
 *  Creates a spinner with the desire configuration
 *
 *  @param config    spinner style configuration
 *  @param text      spinner text
 */
- (id)initWithConfig:(MLSpinnerConfig *)config text:(nullable NSString *)text;

/**
 *  Sets spinner text
 *
 *  @param text spinner text
 */
- (void)setText:(nullable NSString *)text;

/**
 *  Sets spinner style
 *
 *  @param style     spinner style
 */
- (void)setStyle:(MLSpinnerStyle)style __attribute__((deprecated("We recommend start using the setUpSpinnerWithConfig: instead.")));

/**
 *  Sets spinner style configuration
 *
 *  @param config     spinner style configuration
 */
- (void)setUpSpinnerWithConfig:(MLSpinnerConfig *)config;

- (void)showSpinner;
- (void)hideSpinner;

@end

NS_ASSUME_NONNULL_END
