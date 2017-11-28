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

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@end


@implementation FirstHookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNextButton];
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
    button.frame = CGRectMake(0, -4, self.view.bounds.size.width, 55.0);
    
    _codeTextField.inputAccessoryView = button;
}

#pragma mark - Selectors/handlers
- (IBAction)didTapOnNext {
    
    if (self.actionHandler != nil) {
        
        _messageLabel.text = nil;
        
        if  ([self codeIsValid]) {
            
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
}

- (BOOL)codeIsValid {
    if (self.codeTextField.text.length > 0) {
        if ([self.codeTextField.text isEqualToString:@"1234"]) return true;
        self.messageLabel.text = @"La clave no es válida.";
        return false;
    } else {
        self.messageLabel.text = @"Debes completar este dato.";
        return false;
    }
}

#pragma mark - Hookeable delegates
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
    //self.paymentType.text = [paymentOptionSelected getDescription];
    self.messageLabel.text = nil;
    self.codeTextField.text = nil;
    [self.codeTextField becomeFirstResponder];
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
    return [UIColor fromHex:@"#CA254D"];
}

@end
