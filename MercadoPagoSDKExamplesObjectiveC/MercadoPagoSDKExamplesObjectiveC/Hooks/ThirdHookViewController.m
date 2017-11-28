//
//  ThirdHookViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Eden Torres on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "ThirdHookViewController.h"

@interface ThirdHookViewController ()

@end

@implementation ThirdHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ThirdHookViewController loaded");
}

- (IBAction)didTapOnNext {
    if (self.actionHandler != nil) {
        [self.actionHandler next];
    }
}

- (UIView * _Nonnull)render {
    return self.view;
}

- (void)didReceiveWithHookStore:(HookStore * _Nonnull)hookStore {

}

- (enum PXHookStep)hookForStep {
    return PXHookStepBEFORE_PAYMENT;
}

- (void)renderDidFinish {
    NSLog(@"renderDidFinish");
}

- (BOOL)shouldShowBackArrow {
    return YES;
}

- (BOOL)shouldShowNavigationBar {
    return YES;
}

- (NSString * _Nullable)titleForNavigationBar {
    return @"Soy hook 3";
}

- (UIColor * _Nullable)colorForNavigationBar {
    return nil;
}
@end

