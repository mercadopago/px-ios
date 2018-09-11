//
// UIViewController+SnackBar.m
// MLUI
//
// Created by Sebastián Bravo on 21/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import "UIViewController+SnackBar.h"
#import "MLUISnackBarView.h"
#import "MLUISnackBarProtocol.h"
#import <objc/runtime.h>

@implementation UIViewController (SnackBar)

@dynamic ml_snackBarsArray;

- (void)setMl_snackBarsArray:(NSMutableArray *)snackBars
{
	objc_setAssociatedObject(self, @selector(ml_snackBarsArray), snackBars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)ml_snackBarsArray
{
	return objc_getAssociatedObject(self, @selector(ml_snackBarsArray));
}

- (void)ml_presentSnackBar:(UIView <MLUISnackBarProtocol> *)snackBarView animated:(BOOL)animated
{
	snackBarView.translatesAutoresizingMaskIntoConstraints = NO;

	if (self.ml_snackBarsArray && self.ml_snackBarsArray.count > 0) {
		for (UIView *view in self.ml_snackBarsArray) {
			[view removeFromSuperview];
		}
		[self.ml_snackBarsArray removeAllObjects];
	} else if (!self.ml_snackBarsArray) {
		self.ml_snackBarsArray = [[NSMutableArray alloc] init];
	}

	if (animated) {
		snackBarView.alpha = 0;
	}
	[self.view addSubview:snackBarView];

	[self.ml_snackBarsArray addObject:snackBarView];

	NSArray *constraintsArray = [snackBarView getConstraintsToSuperView];

	[self.view addConstraints:constraintsArray];

	if (animated) {
		__weak typeof(self)weakSelf = self;

		[UIView animateWithDuration:0.3 delay:0.0 options:0 animations: ^{
		    snackBarView.alpha = 1;
		} completion: ^(BOOL finished) {
		    [weakSelf ml_delayedDismissSnackBarIfNeeded:snackBarView animated:animated];
		}];
	} else {
		[self ml_delayedDismissSnackBarIfNeeded:snackBarView animated:animated];
	}

	[self.view layoutIfNeeded];
}

- (void)ml_delayedDismissSnackBarIfNeeded:(UIView <MLUISnackBarProtocol> *)snackBarView animated:(BOOL)animated
{
	__weak typeof(self)weakSelf = self;

	long duration = [snackBarView durationInMilliseconds];
	if (duration >= 0) {
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)*duration / 1000.0);
		dispatch_after(time, dispatch_get_main_queue(), ^{
			[weakSelf ml_dismissSnackBar:snackBarView animated:animated];
		});
	}
}

- (void)ml_dismissSnackBar:(UIView <MLUISnackBarProtocol> *)snackBarView animated:(BOOL)animated
{
	if (animated) {
		snackBarView.alpha = 1;

		__weak UIViewController *weakSelf = self;
		[UIView animateWithDuration:0.3 delay:0.0 options:0 animations: ^{
		    snackBarView.alpha = 0;
		} completion: ^(BOOL finished) {
		    if (finished) {
		        [snackBarView removeFromSuperview];
		        [weakSelf.ml_snackBarsArray removeObject:snackBarView];
			}
		}];
	} else {
		[snackBarView removeFromSuperview];
		[self.ml_snackBarsArray removeObject:snackBarView];
	}
}

- (void)ml_dismissAllSnackBars
{
	for (UIView *snackBarView in self.ml_snackBarsArray) {
		[snackBarView removeFromSuperview];
	}

	[self.ml_snackBarsArray removeAllObjects];
}

@end
