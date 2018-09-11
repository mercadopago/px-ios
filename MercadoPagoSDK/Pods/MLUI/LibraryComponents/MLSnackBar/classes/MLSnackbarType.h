//
// MLSnackbarType.h
// MLUI
//
// Created by Julieta Puente on 26/2/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLSnackbarType : NSObject

/*
** Snackbar background color
*/
@property (nonatomic, strong, readonly) UIColor *backgroundColor;

/*
** Label font color
*/
@property (nonatomic, strong, readonly) UIColor *titleFontColor;

/*
** Button font color
*/
@property (nonatomic, strong, readonly) UIColor *actionFontColor;

/*
** Button font color when pressed
*/
@property (nonatomic, strong, readonly) UIColor *actionFontHighlightColor;

/*
** Button highlighted color
*/
@property (nonatomic, strong, readonly) UIColor *actionBackgroundHighlightColor;

/**
 *  Creates the default type.
 *  To change the default value, create a subclass and override this method.
 *
 */
- (instancetype)init;

/**
 *  Creates the default type.
 *
 *
 */
+ (instancetype)defaultType;

/**
 *  Creates the success type
 *
 */
+ (instancetype)successType;

/**
 *  Creates the warning type
 *
 */
+ (instancetype)warningType;

/**
 *  Creates the error type
 *
 */
+ (instancetype)errorType;

@end
