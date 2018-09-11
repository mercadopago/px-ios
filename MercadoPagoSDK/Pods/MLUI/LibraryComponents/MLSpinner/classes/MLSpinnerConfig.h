//
// MLSpinnerConfig.h
// Pods
//
// Created by Cristian Leonel Gibert on 11/17/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, MLSpinnerSize) {
	MLSpinnerSizeBig,
	MLSpinnerSizeSmall
};

/**
 *  Use this interface to create the spinner custom style configuration
 */
@interface MLSpinnerConfig : NSObject

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic) MLSpinnerSize spinnerSize;

- (id)init __attribute__((unavailable("Must use initWithSize:primaryColor:secondaryColor: instead.")));

- (instancetype)initWithSize:(MLSpinnerSize)size primaryColor:(UIColor *)primaryColor secondaryColor:(UIColor *)secondaryColor;

@end

NS_ASSUME_NONNULL_END
