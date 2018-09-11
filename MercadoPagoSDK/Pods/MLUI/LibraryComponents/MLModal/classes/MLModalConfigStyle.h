//
// MLModalConfigStyle.h
// Pods
//
// Created by Jonatan Urquiza on 9/12/17.
//
//

/**
   Config Object for Modal Style
 */

NS_ASSUME_NONNULL_BEGIN
@interface MLModalConfigStyle : NSObject

@property (nonatomic, readonly, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, strong) UIColor *headerBackgroundColor;
@property (nonatomic, readonly, strong) UIColor *tintColor;
@property (nonatomic, readonly, strong) UIColor *titleColor;
@property (nonatomic, readonly, strong) UIFont *titleFont;
@property (nonatomic, readonly) BOOL showBlurView;

/**
 *  Init config object with colors and configs
 *
 *  @param backgroundColor         modal background color
 *  @param headerBackgroundColor   header modal background color
 *  @param tintColor               buttons and close button color
 *  @param titleColor              header title color
 *  @param titleFont               header title font
 *  @param showBlurView            should show blur view in modal
 */
- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
                  headerBackgroundColor:(UIColor *)headerBackgroundColor
                              tintColor:(UIColor *)tintColor
                             titleColor:(UIColor *)titleColor
                              titleFont:(UIFont *)titleFont
                           showBlurView:(BOOL)showBlurView;

@end
NS_ASSUME_NONNULL_END
