//
// MPSDKLoadingView.h
// MercadoPago
//
// Created by Matias Casanova on 02/10/14.
// Copyright (c) 2014 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLoadingViewTag 1000

@interface MPSDKLoadingView : UIView

- (id)initWithBackgroundColor:(UIColor *)color;
- (id)initWithBackgroundColor:(UIColor *)color loadingText:(NSString *)text;
- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color;

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color loadingText:(NSString *)text;

@property (nonatomic, strong) UIImageView *spinner;

@end
