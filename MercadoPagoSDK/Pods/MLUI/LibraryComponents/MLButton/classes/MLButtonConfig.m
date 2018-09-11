//
// MLButtonConfig.m
// Pods
//
// Created by Cristian Leonel Gibert on 1/31/17.
//
//

#import "MLButtonConfig.h"

@implementation MLButtonConfig

- (BOOL)isEqualToButtonConfig:(MLButtonConfig *)buttonConfig
{
	if (!buttonConfig) {
		return NO;
	}
	BOOL haveEqualDefaultState = (!self.defaultState && !buttonConfig.defaultState) || [self.defaultState isEqual:buttonConfig.defaultState];
	BOOL haveEqualHighlightedState = (!self.highlightedState && !buttonConfig.highlightedState) || [self.highlightedState isEqual:buttonConfig.highlightedState];
	BOOL haveEqualDisableState = (!self.disableState && !buttonConfig.disableState) || [self.disableState isEqual:buttonConfig.disableState];
	BOOL haveEqualLoadingState = (!self.loadingState && !buttonConfig.loadingState) || [self.loadingState isEqual:buttonConfig.loadingState];
	return haveEqualDefaultState && haveEqualHighlightedState && haveEqualDisableState && haveEqualLoadingState;
}

- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	if (![object isKindOfClass:MLButtonConfig.class]) {
		return NO;
	}
	return [self isEqualToButtonConfig:(MLButtonConfig *)object];
}

- (NSUInteger)hash
{
	return self.defaultState.hash ^ self.highlightedState.hash ^ self.disableState.hash ^ self.loadingState.hash;
}

@end
