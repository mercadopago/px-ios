//
// MLRadioButtonCollection.h
// MLUI
//
// Created by Santiago Lazzari on 6/9/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MLRadioButtonCollection manage the exclusiveness of an array of MLRadioButtons
 */
@interface MLRadioButtonCollection : NSObject

/**
 *  Static initialiser that returns an instance of MLRadioButtonCollection.
 *  This method might be called only if you want to create the
 *  MLRadioButton objects, if you already have this object, whether you initialised theme in the
 *  xib file or by code, you might initialise the MLRadioButtonCollection with
 *  radioButtonCollectionWithRadioButtons: initialiser
 *
 *  @parms radioButtonCount    the amount of MLRadioButton objects that might initialise
 *  the return instance
 */
+ (instancetype)radioButtonCollectionWithRadioButtonCount:(NSUInteger)radioButtonCount;

/**
 *  Static initialiser that returns an instance of MLRadioButtonCollection.
 *  This method might be called only if you already have the
 *  MLRadioButton objects, if you dont have this object, you might initialise
 *  the MLRadioButtonCollection with radioButtonCollectionWithRadioButtonCount: initialiser
 *
 *  @parms radioButtons    An NSArray of MLRadioButtons
 */
+ (instancetype)radioButtonCollectionWithRadioButtons:(NSArray *)radioButtons;

/**
 *  Array of MLRadioButtons that will have exclusive selection
 */
- (NSArray *)radioButtons;

/**
 *  Changes the state of the MLRadioButton at the index sent by parameter and sets to off
 *  the old MLRadioButton with state in on
 *
 *  @parms index    index of selected MLRadioButton
 */
- (void)selectRadioButtonAtIndex:(NSUInteger)index;

/**
 *  Returns the index of the currently MLRadioButton with state in on
 */
- (NSUInteger)indexOfSelectedRadioButton;

@end
