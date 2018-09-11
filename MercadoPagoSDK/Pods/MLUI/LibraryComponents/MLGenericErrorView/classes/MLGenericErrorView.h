//
// MLGenericErrorView.h
// MLUI
//
// Created by Josefina Bustamante on 14/11/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MLVoidBlock)(void);

NS_ASSUME_NONNULL_BEGIN
/**
 *  Full screen view with an error message and retry action.
 */
@interface MLGenericErrorView : UIView

/**
 *  Show Retry Button. YES if the ErrorView is showing the retry button.
 */
@property (nonatomic, assign, getter = isRetryButtonVisible) BOOL retryButtonVisible;

/**
 *  Shows a full screen error view.
 *  It is designed to be loaded full screen, but in navigation bar hierarchy.
 *
 *  @param image       Image according to error type.
 *  @param title       Title message for error.
 *  @param subtitle    Subtitle message for error.
 *  @param buttonTitle Retry button title.
 *  @param actionBlock Action that will be executed when tapping button.
 *
 *  @return An instance of MLGenericErrorView.
 */
+ (MLGenericErrorView *)genericErrorViewWithImage:(UIImage *)image
                                            title:(NSString *)title
                                         subtitle:(NSString *)subtitle
                                      buttonTitle:(NSString *)buttonTitle
                                      actionBlock:(nullable MLVoidBlock)actionBlock;
@end

NS_ASSUME_NONNULL_END
