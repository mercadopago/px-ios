//
// MLSnackBar.h
// MLUI
//
// Created by Julieta Puente on 26/2/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSnackbarType.h"

/**
 *
 * Snackbar duration.
 * MLSnackbarDurationIndefinitely : the snackbar wont disappear.
 * MLSnackbarDurationShort : the snackbar will disappear after 2 seconds.
 * MLSnackbarDurationLong : the snackbar will disappear after 3.5 seconds.
 *
 */
typedef NS_ENUM (NSInteger, MLSnackbarDuration) {
	MLSnackbarDurationIndefinitely,
	MLSnackbarDurationShort,
	MLSnackbarDurationLong
};

/**
 *  Dismiss cause.
 *  MLSnackbarDismissCauseNone: when the snackbar was dismissed using dismissSnackbar method
 *  MLSnackbarDismissCauseActionButton: when the snackbar was dismissed after tapping the button
 *  MLSnackbarDismissCauseSwipe: when the snackbar was dismissed using swipe interaction
 *  MLSnackbarDismissCauseDuration: when the snackbar was dismissed because duration time expired
 */
typedef NS_ENUM (NSInteger, MLSnackbarDismissCause) {
	MLSnackbarDismissCauseNone,
	MLSnackbarDismissCauseActionButton,
	MLSnackbarDismissCauseSwipe,
	MLSnackbarDismissCauseDuration
};

/**
 *  Dismiss block used as a callback when de snackbar is dismissed
 *
 *  @param cause of the dismiss
 */
typedef void (^MLSnackbarDismissBlock)(MLSnackbarDismissCause cause);

@interface MLSnackbar : UIView

/**
 *  Shows the snackbar. If buttonTitle or actionBlock are nil, the snackbar wont show the actionButton.
 *
 *  @param title                    snackbar message
 *  @param buttonTitle              snackbar button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissGestureEnabled    determines if snackbar can be dismiss by gesture
 */
+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled;

/**
 *  Shows a snackbar with no button.
 *
 *  @param title                    snackbar message
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissGestureEnabled    determines if snackbar can be dismiss by gesture
 */
+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled;

/**
 *  Shows a snackbar that can be dismiss by a geture. If buttonTitle or actionBlock are nil, the snackbar wont show the actionButton.
 *
 *  @param title                    snackbar message
 *  @param buttonTitle              snackbar button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 */
+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration;

/**
 *  Shows a snackbar with no button that can be dismiss by a geture.
 *
 *  @param title                    snackbar message
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 */
+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration;

/**
 *  Shows the snackbar. If buttonTitle or actionBlock are nil, the snackbar wont show the actionButton.
 *
 *  @param title                    snackbar message
 *  @param buttonTitle              snackbar button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissGestureEnabled    determines if snackbar can be dismiss by gesture
 *  @param dismissBlock				block to be applied when the snackbar is dismissed
 */
+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled dismissBlock:(MLSnackbarDismissBlock)dismissBlock;

/**
 *  Shows a snackbar with no button.
 *
 *  @param title                    snackbar message
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissGestureEnabled    determines if snackbar can be dismiss by gesture
 *  @param dismissBlock				block to be applied when the snackbar is dismissed
 */
+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled dismissBlock:(MLSnackbarDismissBlock)dismissBlock;

/**
 *  Shows a snackbar that can be dismiss by a geture. If buttonTitle or actionBlock are nil, the snackbar wont show the actionButton.
 *
 *  @param title                    snackbar message
 *  @param buttonTitle              snackbar button title
 *  @param actionBlock              block to be applied when button is pressed
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissBlock				block to be applied when the snackbar is dismissed
 */
+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissBlock:(MLSnackbarDismissBlock)dismissBlock;

/**
 *  Shows a snackbar with no button that can be dismiss by a geture.
 *
 *  @param title                    snackbar message
 *  @param type                     snackbar type. Determines the style of the snackbar
 *  @param duration                 time for the snackbar to disappear
 *  @param dismissBlock				block to be applied when the snackbar is dismissed
 */
+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissBlock:(MLSnackbarDismissBlock)dismissBlock;

/**
 *  Dismiss the snackbar
 */
- (void)dismissSnackbar;
@end
