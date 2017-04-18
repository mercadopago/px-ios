//
// UIView+RotateView.m
// Pods
//
// Created by Matias Casanova on 17/11/15.
//
//

#import "UIView+RotateView.h"
#import <QuartzCore/QuartzCore.h>

#define kRotationAnimationKey @"rotationAnimation"

@implementation UIView (RotateView)
- (void)rotateViewWithDuration:(CGFloat)duration
{
	// rotate with quartzCore
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 /* full rotation*/ * 10 * 1];
	rotationAnimation.duration = duration;
	rotationAnimation.cumulative = YES;
	rotationAnimation.repeatCount = HUGE_VALF;

	[self.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
}

- (void)stopRotation
{
	[self.layer removeAnimationForKey:kRotationAnimationKey];
}

@end
