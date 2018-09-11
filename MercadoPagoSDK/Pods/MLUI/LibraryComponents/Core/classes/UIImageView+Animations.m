//
// UIImageView+Animations.m
// MLUI
//
// Created by Leandro Fantin on 10/2/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "UIImageView+Animations.h"

@implementation UIImageView (Animations)

- (void)ml_fadeInWithImage:(UIImage *)image andDuration:(NSTimeInterval)interval completionBlock:(void (^)(BOOL finished))completionBlock
{
	self.alpha = 0;
	self.image = image;

	[UIView animateWithDuration:interval animations: ^{
	    self.alpha = 1.0f;
	} completion:completionBlock];
}

- (void)ml_fadeOutWithImage:(UIImage *)image andDuration:(NSTimeInterval)interval completionBlock:(void (^)(BOOL finished))completionBlock
{
	self.alpha = 1.0f;
	self.image = image;

	[UIView animateWithDuration:interval animations: ^{
	    self.alpha = 0;
	} completion:completionBlock];
}

@end
