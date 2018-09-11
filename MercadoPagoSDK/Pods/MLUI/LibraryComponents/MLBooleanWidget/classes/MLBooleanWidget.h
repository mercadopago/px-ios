//
// MLSelectionWidget.h
// MLUI
//
// Created by Santiago Lazzari on 6/14/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLBooleanWidgetDelegate;

@interface MLBooleanWidget : UIView

/**
 *  Static initialiser that returns an instance of MLBooleanWidget.
 *
 *  @parms delegate    Any object that implements MLBooleanWidgetDelegate
 */
+ (instancetype)booleanWidgetWithDelegate:(id <MLBooleanWidgetDelegate>)delegate;

/**
 *  Any object that implements MLSelectionWidgetDelegate, this protocol will alert the object when
 *  the widget who he is the delegate from is tapped
 */
@property (weak, nonatomic) id <MLBooleanWidgetDelegate> delegate;

/**
 *  Changes de state of the widget to on with animation
 */
- (void)on;

/**
 *  Changes de state of the widget to on
 *
 *  @params animated whether the transition is with or without animation
 */
- (void)onAnimated:(BOOL)animated;

/**
 *  Changes de state of the widget to off with animation
 */
- (void)off;

/**
 *  Changes de state of the widget to off
 *
 *  @params animated whether the transition is with or without animation
 */
- (void)offAnimated:(BOOL)animated;

/**
 *  Toggles de state with animation of the widget to on if its current state is off, or to off if its current state is on
 */
- (void)toggle;

/**
 *  Toggles de state of the widget to on if its current state is off, or to off if its current state is on
 *
 *  @params animated whether the transition is with or without animation
 */
- (void)toggleAnimated:(BOOL)animated;

/**
 *  Returns YES if the state of the widget is on, and NO if is off
 */
- (BOOL)isOn;

/**
 *  Returns YES if the state of the widget is off, and NO if is on
 */
- (BOOL)isOff;

/**
 *  Returns YES if the Widget is enabled and NO if it is not.
 */
- (BOOL)isEnabled;

/**
 *  Sets the Widget either to enabled or disabled with or without an animation.
 */
- (void)setEnabled:(BOOL)enabled Animated:(BOOL)animated;

@end

/**
 *  Protocol that notifies the delegate of a MLSelectionWidget when whis one is tapped
 */
@protocol MLBooleanWidgetDelegate <NSObject>

/**
 *  Method that calls the MLBoolean Widget requests a change of state
 */
- (void)booleanWidgetDidRequestChangeOfState:(MLBooleanWidget *)booleanWidget;

@optional
/**
 *  Method that calls the MLBoolean Widget when this one is tapped
 */
- (void)booleanWidgetWasTapped:(MLBooleanWidget *)booleanWidget __attribute__((deprecated("Use booleanWidgetDidRequestChangeOfState:")));

@end
