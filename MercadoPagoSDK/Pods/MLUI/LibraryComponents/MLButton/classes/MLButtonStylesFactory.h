//
// MLButtonStylesFactory.h
// Pods
//
// Created by Cristian Leonel Gibert on 1/31/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLButtonConfig;

typedef NS_ENUM (NSInteger, MLButtonType) {
	MLButtonTypePrimaryAction = 0,
	MLButtonTypeSecondaryAction,
	MLButtonTypePrimaryOption,
	MLButtonTypeSecondaryOption,
	MLButtonTypeLoading
};

@interface MLButtonStylesFactory : NSObject

+ (MLButtonConfig *)configForButtonType:(MLButtonType)buttonType;

@end

NS_ASSUME_NONNULL_END
