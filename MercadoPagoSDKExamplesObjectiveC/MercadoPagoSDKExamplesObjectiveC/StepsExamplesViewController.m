//
//  StepsExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "StepsExamplesViewController.h"
#import "ExampleUtils.h"
@import MercadoPagoSDK;

@interface StepsExamplesViewController ()

@end

@implementation StepsExamplesViewController

PaymentMethod *paymentMethod;
Token *currentToken;
Issuer *selectedIssuer;
int installmentsSelected = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    paymentMethod = [[PaymentMethod alloc] init];
    paymentMethod._id = @"visa";
    paymentMethod.name = @"visa";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self startPaymentVault];
            break;
        case 1:
            [self startCardFlow];
            break;
        case 2:
            [self startCardForm];
            break;
        case 3:
            [self startPaymentMethods];
            break;
        case 4:
            [self statIssuersStep];
            break;
        case 5:
            [self startInstallmentsStep];
            break;
        case 6:
            [self createPayment];
            break;
        default:
            break;
    }
}

- (void)startPaymentVault {
    
    UIViewController *paymentVaultVC = [MPFlowBuilder startPaymentVaultViewController:AMOUNT paymentPreference:nil callback:^(PaymentMethod *pm, Token *token, Issuer *issuer, PayerCost *payerCost) {
        currentToken = token;
        selectedIssuer = issuer;
        paymentMethod = pm;
    } callbackCancel:nil];
   
    [self presentViewController:paymentVaultVC animated:YES completion:^{}];

}



- (void)startCardFlow {
    
    UINavigationController *cf = [MPFlowBuilder startCardFlow:nil amount:AMOUNT cardInformation:nil paymentMethods:nil token:nil timer:nil callback:^(PaymentMethod * pm, Token * token, Issuer * issuer, PayerCost * payercost) {
        currentToken = token;
        selectedIssuer = issuer;
        paymentMethod = pm;
        [self dismissViewControllerAnimated:YES completion:^{}];
    } callbackCancel:^{
        [self dismissViewControllerAnimated:YES completion:^{}];
    }];
    
    [self presentViewController:cf animated:YES completion:^{}];

}

-(void)startCardForm {

    UINavigationController *cf = [MPStepBuilder startCreditCardForm:nil amount:1000 cardInformation:nil paymentMethods:nil token:nil timer:nil callback:^(PaymentMethod *pm, Token *token, Issuer *issuer) {
        currentToken = token;
        selectedIssuer = issuer;
        paymentMethod = pm;
        [self dismissViewControllerAnimated:YES completion:^{}];
    } callbackCancel:^{
        [self dismissViewControllerAnimated:YES completion:^{}];
    }];
   
    
    [self presentViewController:cf animated:YES completion:^{}];
    
}

- (void)startPaymentMethods {
    
    UIViewController *paymentsStep = [MPStepBuilder startPaymentMethodsStepWithPreference:nil callback:^(PaymentMethod * pm) {
        paymentMethod = pm;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:paymentsStep animated:YES];

}

- (void)statIssuersStep {
    UIViewController *issuersVC = [MPStepBuilder startIssuersStep:paymentMethod callback:^(Issuer *issuer) {
        selectedIssuer = issuer;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:issuersVC animated:YES];
    
}

- (void)startInstallmentsStep{
    
     UIViewController *installmentVC =[MPStepBuilder startInstallmentsStep:nil paymentPreference:nil amount:ITEM_UNIT_PRICE issuer:selectedIssuer paymentMethodId:@"visa" callback:^(PayerCost * _Nullable payerCost) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
     [self.navigationController pushViewController:installmentVC animated:YES];
}

- (void)createPayment {
    
    [MercadoPagoContext setPublicKey:MERCHANT_PUBLIC_KEY];
    [MercadoPagoContext setBaseURL:MERCHANT_MOCK_BASE_URL];
    [MercadoPagoContext setPaymentURI:MERCHANT_MOCK_CREATE_PAYMENT_URI];
    
    Item *item = [[Item alloc] initWith_id:ITEM_ID title:ITEM_TITLE quantity:ITEM_QUANTITY unitPrice:ITEM_UNIT_PRICE description:nil];

    MerchantPayment *merchantPayment = [[MerchantPayment alloc] initWithItems:[NSArray arrayWithObject:item] installments:installmentsSelected cardIssuer:selectedIssuer tokenId:[currentToken _id] paymentMethod:paymentMethod campaignId:0];
    
    
    [MerchantServer createPayment:merchantPayment success:^(Payment *payment) {
        NSLog(@"Payment created with id: %ld", payment._id);
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
}


@end
