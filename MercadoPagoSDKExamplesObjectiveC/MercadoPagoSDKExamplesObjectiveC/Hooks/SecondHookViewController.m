//
//  SecondHookViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Eden Torres on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "SecondHookViewController.h"

@interface SecondHookViewController ()

@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property PaymentData *paymentData;
@property (strong, nonatomic) PXHookNavigationHandler * navigationHandler;

@end

@implementation SecondHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SecondHookViewController loaded");
}

- (IBAction)didTapOnNext {
    if (self.navigationHandler != nil) {
        [self.navigationHandler next];
    }
}


#pragma mark - PXHookComponent mandatory delegates.
- (UIView * _Nullable)renderWithStore:(PXCheckoutStore * _Nonnull)store {
    return self.view;
}

- (enum PXHookStep)hookForStep {
    return PXHookStepAFTER_PAYMENT_METHOD_CONFIG;
}


#pragma mark - PXHookComponent optional delegates.
- (BOOL)shouldSkipHookWithHookStore:(PXCheckoutStore * _Nonnull)hookStore {
    return [[[hookStore getPaymentOptionSelected] getId] isEqualToString:@"bitcoin_payment"];
}

- (void)didReceiveWithHookStore:(PXCheckoutStore * _Nonnull)hookStore {
    self.paymentData = [hookStore getPaymentData];
}

- (void)renderDidFinish {
    self.paymentMethodLabel.text = self.paymentData.paymentMethod.paymentMethodId;
    NSLog(@"renderDidFinish");
}

- (BOOL)shouldShowBackArrow {
    return YES;
}

- (BOOL)shouldShowNavigationBar {
    return YES;
}

- (NSString * _Nullable)titleForNavigationBar {
    return @"Soy hook 2";
}

- (UIColor * _Nullable)colorForNavigationBar {
    return nil;
}
- (void)navigationHandlerForHookWithNavigationHandler:(PXHookNavigationHandler *)navigationHandler {
    self.navigationHandler = navigationHandler;
}

@end
