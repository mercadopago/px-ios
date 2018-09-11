//
// MLUISnackBarProtocol.h
// MLUI
//
// Created by Sebastián Bravo on 21/7/15.
// Copyright (c) 2015 MercadoLibre. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLUISnackBarViewActionButtonBlock)(void);

@protocol MLUISnackBarProtocol <NSObject>

@property (nonatomic, copy) MLUISnackBarViewActionButtonBlock actionButtonBlock;

- (NSArray *)getConstraintsToSuperView;
- (void)setActionButtonHidden:(BOOL)hidden;
- (long)durationInMilliseconds;

@end
