//
//  FirstHookViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 23/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "FirstHookViewController.h"

id <PaymentMethodOption> paymentOptionSelected;

@interface FirstHookViewController ()

@property (weak, nonatomic) IBOutlet UILabel *paymentType;

@end


@implementation FirstHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"FirstHookViewController loaded");
}

- (IBAction)didTapOnNext {
    if (self.actionHandler != nil) {
        [self.actionHandler back];
    }
}

- (UIView * _Nonnull)render {
    return self.view;
}

- (void)didReciveWithHookStore:(HookStore * _Nonnull)hookStore {
    paymentOptionSelected = [hookStore getPaymentOptionSelected];
}

- (enum HookStep)getStep {
    return HookStepSTEP1;
}

- (void)renderDidFinish {
    self.paymentType.text = [paymentOptionSelected getDescription];
    NSLog(@"renderDidFinish");
}

- (BOOL)shouldShowBackArrow {
    return YES;
}

- (BOOL)shouldShowNavigationBar {
    return YES;
}

- (NSString * _Nullable)titleForNavigationBar {
    return nil;
}

- (UIColor * _Nullable)colorForNavigationBar {
    return nil;
}

@end
