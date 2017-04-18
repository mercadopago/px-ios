//
//  MLSpinnerConfig.h
//  Pods
//
//  Created by Cristian Leonel Gibert on 11/17/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

- (instancetype)initWithSize:(MLSpinnerSize)size primaryColor:(nonnull UIColor *)primaryColor secondaryColor:(nonnull UIColor *)secondaryColor;

@end
