//
//  ThirdHookViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Eden Torres on 11/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "ThirdHookViewController.h"

@interface ThirdHookViewController ()
@property (strong, nonatomic) PXHookNavigationHandler * navigationHandler;
@end

@implementation ThirdHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ThirdHookViewController loaded");
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
    return PXHookStepBEFORE_PAYMENT;
}


#pragma mark - PXHookComponent optional delegates.

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

- (void)navigationHandlerForHookWithNavigationHandler:(PXHookNavigationHandler *)navigationHandler {
    self.navigationHandler = navigationHandler;
}

@end
