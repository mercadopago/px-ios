//
// MLCheckList.h
// MLUI
//
// Created by Santiago Lazzari on 6/15/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MLCheckList manage the multiple selection of an array of MLCheckBox
 */
@interface MLCheckList : NSObject

/**
 *  Static initialiser that returns an instance of MLCheckList.
 *  This method might be called only if you want to create the
 *  MLRadioButton objects, if you already have this object, whether you initialised theme in the
 *  xib file or by code, you might initialise the MLCheckList with
 *  checkListWithCheckButtons: initialiser
 *
 *  @parms checkBoxCount    the amount of MLRadioButton objects that might initialise
 *  the return instance
 */
+ (instancetype)checkListWithCheckBoxCout:(NSUInteger)checkBoxCount;

/**
 *  Static initialiser that returns an instance of MLCheckList.
 *  This method might be called only if you already have the
 *  MLCheckBox objects, if you dont have this object, you might initialise
 *  the MLCheckList with radioButtonCollectionWithRadioButtonCount: initialiser
 *
 *  @parms checkBoxes    An array of MLCheckBox
 */
+ (instancetype)checkListWithCheckBoxes:(NSArray *)checkBoxes;

/**
 *  Returns an array of MLCheckBox
 */
- (NSArray *)checkBoxes;

/**
 *  Toggles de state of the MLCheckBox to on if its current state is off, or to off if its current state is on
 */
- (void)toggleCheckBoxAtIndex:(NSUInteger)index;

/**
 *  Returns the indexes in an array of the currently MLCheckBox with state in on
 */
- (NSArray *)indexesOfSelectedCheckBoxes;

@end
