//
//  MainExamplesViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MercadoPagoSDK;

@interface MainExamplesViewController : UITableViewController <PXCheckoutLifecycleProtocol>

@property MercadoPagoCheckoutBuilder *checkoutBuilder;
@property MercadoPagoCheckout *mpCheckout;

@property CheckoutPreference *pref;
@property PXPaymentConfiguration *paymentConfig;

+(void)setPaymentDataCallback;

@end
