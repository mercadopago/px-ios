//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "ExampleUtils.h"
@import MercadoPagoSDK;


@implementation MainExamplesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //[MercadoPagoContext setPublicKey:TEST_PUBLIC_KEY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkoutFlow:(id)sender {

    
    UINavigationController *choFlow = [MPFlowBuilder startCheckoutViewController:PREF_ID_NO_EXCLUSIONS callback:^(Payment *payment) {
    } callbackCancel:nil];
    [self presentViewController:choFlow animated:YES completion:^{}];
}


@end
