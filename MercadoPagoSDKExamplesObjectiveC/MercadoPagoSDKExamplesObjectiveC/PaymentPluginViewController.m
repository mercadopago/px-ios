//
//  PaymentPluginViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentPluginViewController.h"

@interface PaymentPluginViewController ()

@property (strong, nonatomic) PXPluginNavigationHandler * pluginNavigationHandler;

@end

@implementation PaymentPluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Plugin implementation.
- (UIView * _Nonnull)render {
    return self.view;
}

- (void)renderDidFinish {
    
    [self.pluginNavigationHandler showLoading];
    
    double delay = 3.0;
    dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(tm, dispatch_get_main_queue(), ^(void){
        [self.pluginNavigationHandler hideLoading];
        [self.pluginNavigationHandler didFinishPaymentWithPaymentStatus:RemotePaymentStatusREJECTED receiptId:@"ABCD"];
    });
}

- (void)navigationHandlerForPluginWithNavigationHandler:(PXPluginNavigationHandler *)navigationHandler {
    self.pluginNavigationHandler = navigationHandler;
}

@end
