//
// MLModal.h
// MLUI
//
// Created by Julieta Puente on 7/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLModalConfigStyle.h"
#import "MLModalStyleFactory.h"

@interface MLModal : NSObject

/**
 * Dismiss block is call right after the modal pop out.
 * Use this method if you are triying to push a wiew
 * controller after hide the modal.
 */
@property (nonatomic, copy) void (^dismissBlock)(void);

/**
 *  Shows a modal with title and two buttons. If actionTitle or actionBlock are nil, the modal wont show the
 *  actionButton. If the secondaryTitle or secondaryActionBlock are nil, the modal wont show the secondary
 *  button. Stylize modal from modal type
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title                    modal title
 *  @param actionTitle              modal button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param secondaryTitle           modal secondary button title
 *  @param secondaryActionBlock     block to be applied when the secondary button is pressed
 *  @param dismissBlock             block to be applied when the modal is dismissed
 *  @param enable                   indicates if viewcontroller should be added to a scrollView
 *  @param type                     indicates style of modal
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable type:(MLModalType) type __deprecated_msg("This method is deprecated, use some of the others initializers");

/**
 *  Shows a modal with title and two buttons. If actionTitle or actionBlock are nil, the modal wont show the
 *  actionButton. If the secondaryTitle or secondaryActionBlock are nil, the modal wont show the secondary
 *  button. Custom modal style from config style object
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title                    modal title
 *  @param actionTitle              modal button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param secondaryTitle           modal secondary button title
 *  @param secondaryActionBlock     block to be applied when the secondary button is pressed
 *  @param dismissBlock             block to be applied when the modal is dismissed
 *  @param enable                   indicates if viewcontroller should be added to a scrollView
 *  @param configStyle              modal config for set modal style
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable configStyle:(MLModalConfigStyle *)configStyle;

/**
 *  Shows a modal with title and two buttons. If actionTitle or actionBlock are nil, the modal wont show the
 *  actionButton. If the secondaryTitle or secondaryActionBlock are nil, the modal wont show the secondary
 *  button
 *
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title                    modal title
 *  @param actionTitle              modal button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param secondaryTitle           modal secondary button title
 *  @param secondaryActionBlock     block to be applied when the secondary button is pressed
 *  @param dismissBlock             block to be applied when the modal is dismissed
 *  @param enable                   indicates if viewcontroller should be added to a scrollView
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable;

/**
 *  Shows a plain modal.
 *
 *  @param innerViewController      view controller to show on the modal
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController;

/**
 *  Shows a plain modal.
 *
 *  @param innerViewController      view controller to show on the modal
 *  @param dismissBlock             block to be applied when the modal is dismissed
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController dismissBlock:(void (^)(void))dismissBlock;

/**
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title   modal title
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title;

/**
 *  Shows a modal with title and one button.
 *
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title                    modal title
 *  @param actionTitle              modal button title
 *  @param actionBlock              block to be applied when button is pressed
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock;

/**
 *  Shows a modal with one button.
 *
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param actionTitle              modal button title
 *  @param actionBlock              block to be applied when button is pressed
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock;

/**
 *  Shows a modal with title and a secondary button.
 *
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param title                    modal title
 *  @param secondaryTitle           modal secondary button title
 *  @param secondaryActionBlock     block to be applied when the secondary button is pressed
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock;

/**
 *  Shows a plain modal with a secondary button.
 *
 *  @param innerViewController      viewController to show on the modal. View needs to have autolayout, and its width
 *                                  cannot be fixed.
 *  @param secondaryTitle           modal secondary button title
 *  @param secondaryActionBlock     block to be applied when the secondary button is pressed
 */
+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock;

/**
 *  Dismiss modal.
 */
- (void)dismissModal;
@end
