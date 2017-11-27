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
    
        // Loading example
        [self.actionHandler showLoading];
        
        double delay = 3.0;
        dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
        dispatch_after(tm, dispatch_get_main_queue(), ^(void){
            // Hide loading and back action example
            [self.actionHandler hideLoading];
            [self.actionHandler back];
        });
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
    return @"Clave de pagos y retiros";
}

- (UIColor * _Nullable)colorForNavigationBar {
    return UIColor.mpDefaultColor;
}

@end
