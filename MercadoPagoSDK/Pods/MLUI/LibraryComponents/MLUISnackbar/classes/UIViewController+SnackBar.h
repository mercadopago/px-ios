//
// UIViewController+SnackBar.h
// MLUI
//
// Created by Sebastián Bravo on 21/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLUISnackBarProtocol;

@interface UIViewController (SnackBar)

@property (nonatomic, strong) NSMutableArray *ml_snackBarsArray;

/**
 *  Display a snackbar hiding all previous displayed snackbars
 *
 *  @param snackBarView Snackbar to be displayed
 *  @param animated     flag if needs animation
 */
- (void)ml_presentSnackBar:(id <MLUISnackBarProtocol>)snackBarView animated:(BOOL)animated;

/**
 *  Hides a snackbar with animation
 *
 *  @param snackBarView Snackbar to be displayed
 *  @param animated     flag if needs animation
 */
- (void)ml_dismissSnackBar:(UIView <MLUISnackBarProtocol> *)snackBarView animated:(BOOL)animated;

/**
 *  Hide all snackbars
 */
- (void)ml_dismissAllSnackBars;

@end
