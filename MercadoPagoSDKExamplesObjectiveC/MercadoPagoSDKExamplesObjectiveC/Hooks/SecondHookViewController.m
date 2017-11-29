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

@end

@implementation SecondHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SecondHookViewController loaded");
}

- (IBAction)didTapOnNext {
    if (self.actionHandler != nil) {
        [self.actionHandler next];
    }
}

#pragma mark - PXHookComponent delegates
- (UIView * _Nonnull)render {
    return self.view;
}

- (enum PXHookStep)hookForStep {
    return PXHookStepAFTER_PAYMENT_METHOD_SELECTED;
}

- (BOOL)shouldSkipHookWithHookStore:(PXHookStore * _Nonnull)hookStore {
    self.paymentData = [hookStore getPaymentData];
    return NO;
}

- (void)renderDidFinish {
    self.paymentMethodLabel.text = self.paymentData.paymentMethod._id;
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

@end
