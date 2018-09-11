//
// MLUIBannerErrorView.h
// MLUI
//
// Created by Sebastián Bravo on 14/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLUISnackBarProtocol.h"

typedef NS_ENUM (NSInteger, MLUISnackBarDuration) {
	MLSnackBarDurationNone = 0,
	MLSnackBarDurationShort,
	MLSnackBarDurationLong
};

@interface MLUISnackBarView : UIView <MLUISnackBarProtocol>

@property (nonatomic, readonly) MLUISnackBarDuration duration;

/**
 *  Make a Snackbar to display a message
 *
 *  @param duration How long to display the message
 *
 *  @return a new MLSnackBarView object
 */
+ (MLUISnackBarView *)snackBar:(MLUISnackBarDuration)duration;

/**
 *  Setter for message
 *
 *  @param message a text to display
 */
- (void)setMessage:(NSString *)message;

// Se setea al boton el texto para como parámetro. Si no se setea, se usa un texto por default.
- (void)setActionButtonText:(NSString *)text;

@end
