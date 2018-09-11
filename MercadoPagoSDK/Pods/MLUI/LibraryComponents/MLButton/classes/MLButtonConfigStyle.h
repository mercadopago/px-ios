//
// MLButtonConfigStyle.h
// Pods
//
// Created by Cristian Leonel Gibert on 1/12/17.
//
//

NS_ASSUME_NONNULL_BEGIN

/**
 *  Use this interface to create the button custom style configuration
 */
@interface MLButtonConfigStyle : NSObject

@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;

- (instancetype)init __attribute__((unavailable("Must use initWithContentColor:backgroundColor:borderColor: instead.")));

- (instancetype)initWithContentColor:(UIColor *)contentColor backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
