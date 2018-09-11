//
//  StepsExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "StepsExamplesViewController.h"
#import "ExampleUtils.h"
#import "MainExamplesViewController.h"
@import MercadoPagoSDKV4;
@import MercadoPagoServicesV4;

@interface StepsExamplesViewController ()

@end

@implementation StepsExamplesViewController

CheckoutPreference *pref;

- (void)viewDidLoad {
    [super viewDidLoad];
  
    Item *item = [[Item alloc] initWithItemId:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWithItemId:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    PXPayer *payer = [[PXPayer alloc]init];
    payer.email = @"sarasa@gmail.com";
    
    NSArray *items = [NSArray arrayWithObjects:item2, item2, nil];
    
    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", nil];
    //paymentExclusions.defaultInstallments = 1;
    
    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:nil];  
    self.pref.paymentPreference = paymentExclusions;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self startReviewAndConfirm];
            break;
        case 1:
            [self skipReviewAndConfirm];
            break;
        case 2:
            [self showCongrats];
            break;
        case 3:
            [self startCardForm];
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

- (void)startReviewAndConfirm {
    
    //WALLET CONFIGS
    [MercadoPagoContext setLanguageWithLanguage:Languages_SPANISH];
    
    [MercadoPagoContext setPublicKey:@"APP_USR-5bd14fdd-3807-446f-babd-095788d5ed4d"];
    [MercadoPagoContext setAccountMoneyAvailableWithAccountMoneyAvailable:YES];
    [MercadoPagoContext setDisplayDefaultLoadingWithFlag:NO];
    [CardFormViewController setShowBankDeals:NO];
    
    
    
    [[[MercadoPagoCheckout alloc] initWithPublicKey: TEST_PUBLIC_KEY accessToken: @"APP_USR-1094487241196549-081708-4bc39f94fd147e7ce839c230c93261cb__LA_LC__-145698489" checkoutPreference:self.pref paymentData:nil discount:nil navigationController:self.navigationController] start];

    
}



- (void)skipReviewAndConfirm {
    
    FlowPreference *fp = [[FlowPreference alloc] init];
    [fp disableReviewAndConfirmScreen];
    [MercadoPagoCheckout setFlowPreference:fp];
    
    [MainExamplesViewController setPaymentDataCallback];
    
    [[[MercadoPagoCheckout alloc] initWithPublicKey: TEST_PUBLIC_KEY accessToken: @"APP_USR-1094487241196549-081708-4bc39f94fd147e7ce839c230c93261cb__LA_LC__-145698489" checkoutPreference:self.pref discount:nil navigationController:self.navigationController] start];

}

-(void)startCardForm {

    //Empty
}

- (void)showCongrats {


}

- (void)statIssuersStep {
//    UIViewController *issuersVC = [MPStepBuilder startIssuersStep:paymentMethod callback:^(Issuer *issuer) {
//        selectedIssuer = issuer;
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//    [self.navigationController pushViewController:issuersVC animated:YES];
    
}

- (void)startInstallmentsStep{
    
//     UIViewController *installmentVC =[MPStepBuilder startInstallmentsStep:nil paymentPreference:nil amount:ITEM_UNIT_PRICE issuer:selectedIssuer paymentMethodId:@"visa" callback:^(PayerCost * _Nullable payerCost) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//     [self.navigationController pushViewController:installmentVC animated:YES];
}

- (void)createPayment {
    
//    [MercadoPagoContext setBaseURL:MERCHANT_MOCK_BASE_URL];
//    [MercadoPagoContext setPaymentURI:MERCHANT_MOCK_CREATE_PAYMENT_URI];
    
//    Item *item = [[Item alloc] initWith_id:ITEM_ID title:ITEM_TITLE quantity:ITEM_QUANTITY unitPrice:ITEM_UNIT_PRICE description:nil currency:@"ARS"];
//
//    MerchantPayment *merchantPayment = [[MerchantPayment alloc] initWithItems:[NSArray arrayWithObject:item] installments:installmentsSelected cardIssuer:selectedIssuer tokenId:[currentToken _id] paymentMethod:paymentMethod campaignId:0];
//    
    
//    [CustomServer createPayment:merchantPayment success:^(Payment *payment) {
//        NSLog(@"Payment created with id: %ld", payment._id);
//    } failure:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
}



@end
