//
// MLBooleanWidget_Protected.h
// MLUI
//
// Created by Santiago Lazzari on 6/27/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#ifndef MLBooleanWidget_Protected_h
#define MLBooleanWidget_Protected_h

@interface MLBooleanWidget ()

/**
 *  This interface is protected, only use if implementing a MLBoolean child
 *  in all other cases, do not use
 */
@property (nonatomic) BOOL isBooleanWidgetOn;

- (void)setOnBooleanWidgetAnimated:(BOOL)animated;
- (void)setOffBooleanWidgetAnimated:(BOOL)animated;
- (void)commonInit;

@end

#endif /* MLBooleanWidget_Protected_h */
