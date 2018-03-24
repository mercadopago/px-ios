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
- (UIView * _Nullable)renderWithStore:(PXCheckoutStore * _Nonnull)store theme:(id<PXTheme> _Nonnull)theme {
    return self.view;
}

- (void)renderDidFinish {
    
    [self.pluginNavigationHandler showLoading];
    
    double delay = 3.0;
    dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(tm, dispatch_get_main_queue(), ^(void) {
        
        [self.pluginNavigationHandler hideLoading];
        
        PXComponentAction* popeame = [[PXComponentAction alloc] initWithLabel:@"Cancelar" action:^{
            [self.pluginNavigationHandler cancel];
       }];
        PXComponentAction* printeaEnConsola = [[PXComponentAction alloc] initWithLabel:@"Intentar nuevamente" action:^{
            NSLog(@"print !!! action!!");
        }];
        
        PXBusinessResult* businessResult = [[PXBusinessResult alloc] initWithReceiptId:@"12345" status:PXBusinessResultStatusREJECTED title:@"Claro no pudo procesar tu recarga" subtitle:@"Falló la recarga" icon:[UIImage imageNamed:@"claro_logo"] mainAction:printeaEnConsola secondaryAction:popeame helpMessage:@"Intenta mas tarde"];
        [self.pluginNavigationHandler didFinishPaymentWithBusinessResult:businessResult];

       // [self.pluginNavigationHandler didFinishPaymentWithPaymentStatus:RemotePaymentStatusAPPROVED statusDetails:@"" receiptId:nil];
    });
}

- (void)navigationHandlerForPluginWithNavigationHandler:(PXPluginNavigationHandler *)navigationHandler {
    self.pluginNavigationHandler = navigationHandler;
}

@end
