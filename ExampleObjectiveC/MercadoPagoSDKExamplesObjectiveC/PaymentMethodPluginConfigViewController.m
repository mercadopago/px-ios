//
//  PaymentMethodPluginConfigViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentMethodPluginConfigViewController.h"

#import <MLUI/MLButton.h>
#import <MLUI/MLButtonStylesFactory.h>

@interface PaymentMethodPluginConfigViewController() <PXPaymentMethodConfigProtocol>

@property (strong, nonatomic) PXPluginNavigationHandler * pluginNavigationHandler;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *walletTextField;

@end

@implementation PaymentMethodPluginConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _messageLabel.text = nil;
    [_walletTextField becomeFirstResponder];
}

#pragma mark - Setup methods
- (void)setupNextButton {
    MLButton *button = [[MLButton alloc] initWithConfig:[MLButtonStylesFactory configForButtonType:MLButtonTypePrimaryAction]];
    [button addTarget:self
               action:@selector(didTapOnNext)
     forControlEvents:UIControlEventTouchUpInside];
    button.buttonTitle = @"Continuar";
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
- (UIView * _Nullable)renderWithStore:(PXCheckoutStore * _Nonnull)store theme:(id<PXTheme> _Nonnull)theme {
    return self.view;
}

- (void)navigationHandlerForPluginWithNavigationHandler:(PXPluginNavigationHandler *)navigationHandler {
    self.pluginNavigationHandler = navigationHandler;
}

- (UIViewController * _Nullable)configViewController {
    return self;
}


@end
