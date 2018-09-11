//
//  PaymentPluginViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentPluginViewController.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"

@interface PaymentPluginViewController ()

@property (strong, nonatomic) PXPaymentProcessorNavigationHandler * paymentNavigationHandler;
@end

@implementation PaymentPluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self makePayment];
}

- (void)makePayment {
    [self.paymentNavigationHandler showLoading];

    double delay = 3.0;
    dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(tm, dispatch_get_main_queue(), ^(void) {

        [self.paymentNavigationHandler hideLoading];

        CustomComponentText* component = [[CustomComponentText alloc] init];
        PXAction* popeame = [[PXAction alloc] initWithLabel:@"Continuar" action:^{
            //[self.paymentNavigationHandler cancel];
        }];

        PXAction* printeaEnConsola = [[PXAction alloc] initWithLabel:@"Intentar nuevamente" action:^{
            NSLog(@"print !!! action!!");
        }];

        PXBusinessResult* businessResult = [[PXBusinessResult alloc] initWithReceiptId:@"1879867544" status:PXBusinessResultStatusAPPROVED title:@"¡Listo! Ya pagaste en YPF" subtitle:nil icon:[UIImage imageNamed:@"ypf"] mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:@"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/YPF.svg/2000px-YPF.svg.png" topCustomView:[component render] bottomCustomView: nil paymentStatus:@"" paymentStatusDetail:@""];
        [self.paymentNavigationHandler didFinishPaymentWithBusinessResult:businessResult];
    });
}

#pragma mark - Payment Plugin implementation.
- (UIViewController * _Nullable)paymentProcessorViewController {
    return nil;
}

- (BOOL)support {
    return true;
}

-(void)startPaymentWithCheckoutStore:(PXCheckoutStore *)checkoutStore errorHandler:(id<PXPaymentProcessorErrorHandler>)errorHandler successWithBusinessResult:(void (^)(PXBusinessResult * _Nonnull))successWithBusinessResult successWithPaymentResult:(void (^)(PXGenericPayment * _Nonnull))successWithPaymentResult {
    PXGenericPayment* result = [[PXGenericPayment alloc] initWithStatus:@"approved" statusDetail:@"" paymentId: @""];
    successWithPaymentResult(result);
}

-(void)didReceiveWithNavigationHandler:(PXPaymentProcessorNavigationHandler *)navigationHandler {
    self.paymentNavigationHandler = navigationHandler;
}

-(void)didReceiveWithCheckoutStore:(PXCheckoutStore *)checkoutStore {
}
@end
