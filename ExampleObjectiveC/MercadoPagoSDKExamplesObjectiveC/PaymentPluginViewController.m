//
//  PaymentPluginViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentPluginViewController.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"

@interface PaymentPluginViewController() <PXSplitPaymentProcessor>

@property (strong, nonatomic) PXPaymentProcessorNavigationHandler * paymentNavigationHandler;
@end

@implementation PaymentPluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)makePayment {
    [self.paymentNavigationHandler showLoading];

    double delay = 3.0;
    dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(tm, dispatch_get_main_queue(), ^(void) {

        [self.paymentNavigationHandler hideLoading];

        /*
        PXAction* mainAction = [[PXAction alloc] initWithLabel:@"Continuar" action:^{
            //[self.paymentNavigationHandler cancel];
        }]; */

        /*
        PXAction* secondaryAction = [[PXAction alloc] initWithLabel:@"Intentar nuevamente" action:^{
            NSLog(@"print !!! action!!");
        }]; */

        PXBusinessResult* businessResult = [[PXBusinessResult alloc] initWithReceiptId:@"1879867544" status:PXBusinessResultStatusAPPROVED title:@"¡Listo! Ya pagaste en YPF2" subtitle:nil icon:[UIImage imageNamed:@"ypf"] mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:@"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/YPF.svg/2000px-YPF.svg.png" topCustomView:nil bottomCustomView: nil paymentStatus:@"" paymentStatusDetail:@""];
        [self.paymentNavigationHandler didFinishPaymentWithBusinessResult:businessResult];
    });
}

#pragma mark - Payment Plugin implementation.
- (UIViewController * _Nullable)paymentProcessorViewController {
    return nil;
}

- (BOOL)support {
    return YES;
}

- (BOOL)shouldSkipUserConfirmation {
    return NO;
}

-(void)startPaymentWithCheckoutStore:(PXCheckoutStore *)checkoutStore errorHandler:(id<PXPaymentProcessorErrorHandler>)errorHandler successWithBasePayment:(void (^)(id<PXBasePayment> _Nonnull))successWithBasePayment {
    NSString* title = @"¡Listo! Ya pagaste en YPF";
    UIImage* icon = [UIImage imageNamed:@"ypf"];
    PXBusinessResultStatus status = PXBusinessResultStatusAPPROVED;
    NSString* imageUrl = @"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/YPF.svg/2000px-YPF.svg.png";
    NSString* paymentMethodId = [[[checkoutStore getPaymentData] getPaymentMethod] getId];
    NSString* paymentTypeId = [[[checkoutStore getPaymentData] getPaymentMethod] paymentTypeId];
    NSString* securityType = [checkoutStore getSecurityType];

    CustomComponentText* topCustomView = [[CustomComponentText alloc] initWithLabelText:@"Custom view test. PXBusinessResult topCustomView."];
    CustomComponentText* bottomCustomView = [[CustomComponentText alloc] initWithLabelText:@"Custom view test. PXBusinessResult bottomCustomView."];
    CustomComponentText* importantView = [[CustomComponentText alloc] initWithLabelText:@"Important view test. PXBusinessResult importantView."];

    //PAYMENT ID ARGENTINO
//    PXBusinessResult* result = [[PXBusinessResult alloc] initWithReceiptId:@"1879867544" status:status title:title subtitle:nil icon:icon mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:imageUrl topCustomView:[component render] bottomCustomView: nil paymentStatus:@"approved" paymentStatusDetail:@""];

    // PAYMENT ID BRASIL (Test New Congrats)
    PXBusinessResult* result = [[[PXBusinessResult alloc] initWithReceiptId:@"5148665090" status:status title:title subtitle:nil icon:icon mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:imageUrl topCustomView:[topCustomView render] bottomCustomView: [bottomCustomView render] paymentStatus:@"approved" paymentStatusDetail:@"" paymentMethodId: paymentMethodId paymentTypeId: paymentTypeId importantView: [importantView render]] shouldShowReceipt:YES];

    // Success example payment result generic payment.
    // PXGenericPayment* result = [[PXGenericPayment alloc] initWithStatus:@"approved" statusDetail:@"" paymentId: @""];
    // Rejected example payment result generic payment.
    // PXGenericPayment* result = [[PXGenericPayment alloc] initWithStatus:@"rejected" statusDetail:@"" paymentId: @""];

    successWithBasePayment(result);
}

-(void)didReceiveWithNavigationHandler:(PXPaymentProcessorNavigationHandler *)navigationHandler {
    self.paymentNavigationHandler = navigationHandler;
}

-(void)didReceiveWithCheckoutStore:(PXCheckoutStore *)checkoutStore {
}

- (BOOL)supportSplitPaymentMethodPaymentWithCheckoutStore:(PXCheckoutStore * _Nonnull)checkoutStore {
    return NO;
}

- (IBAction)didTapOnPayButton {
    [self makePayment];
}

@end
