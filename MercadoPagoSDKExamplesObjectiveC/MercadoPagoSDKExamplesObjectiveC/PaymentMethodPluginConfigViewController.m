//
//  PaymentMethodPluginConfigViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentMethodPluginConfigViewController.h"

@interface PaymentMethodPluginConfigViewController ()

@property (strong, nonatomic) PXPluginNavigationHandler * pluginNavigationHandler;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *walletTextField;

@end

@implementation PaymentMethodPluginConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNextButton];
}

- (void)viewDidAppear:(BOOL)animated{
    [_walletTextField becomeFirstResponder];
    _messageLabel.text = nil;
}

#pragma mark - Setup methods
- (void)setupNextButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button addTarget:self
               action:@selector(didTapOnNext)
     forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor fromHex:@"#CA254D"]];
    [button setTintColor:UIColor.whiteColor];
    [button setTitle:@"Continuar" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 55.0);
    
    _walletTextField.inputAccessoryView = button;
}


#pragma mark - Selectors/handlers
- (IBAction)didTapOnNext {
    
    if (self.pluginNavigationHandler != nil && [_walletTextField.text length] > 0) {
        _messageLabel.text = nil;
        [self.pluginNavigationHandler next];
    } else {
        _messageLabel.text = @"Debes completar este dato.";
    }
}

#pragma mark - Plugin implementation.

- (UIView * _Nonnull)render {
    return self.view;
}

- (NSString * _Nullable)titleForNavigationBar {
    return @"Pagar con Bitcoin";
}

- (void)renderDidFinish {
    _messageLabel.text = nil;
    [_walletTextField becomeFirstResponder];
}

- (void)navigationHandlerForPluginWithNavigationHandler:(PXPluginNavigationHandler *)navigationHandler {
    self.pluginNavigationHandler = navigationHandler;
}

@end
