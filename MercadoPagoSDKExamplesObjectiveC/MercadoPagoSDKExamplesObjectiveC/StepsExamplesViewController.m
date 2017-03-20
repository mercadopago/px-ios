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
@import MercadoPagoSDK;

@interface StepsExamplesViewController ()

@end

@implementation StepsExamplesViewController

CheckoutPreference *pref;

- (void)viewDidLoad {
    [super viewDidLoad];
  
    Item *item = [[Item alloc] initWith_id:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWith_id:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWith_id:@"payerId" email:@"payer@email.com" type:nil identification:nil];
    
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
    PaymentVaultViewController.maxCustomerPaymentMethods = 100;
    [CardFormViewController setShowBankDeals:NO];
    
    PaymentMethod *pm = [[PaymentMethod alloc] init];
    pm._id = @"debvisa";
    pm.paymentTypeId = @"debit_card";
    pm.name = @"visa";
     
     
    PaymentData *pd = [[PaymentData alloc] init];
    pd.paymentMethod = pm;
     
    pd.token = [[Token alloc] initWith_id:@"id" publicKey:@"pk" cardId:@"" luhnValidation:nil status:nil usedDate:nil cardNumberLength:nil creationDate:nil lastFourDigits:nil firstSixDigit:@"123456" securityCodeLength:3 expirationMonth:11 expirationYear:2012 lastModifiedDate:nil dueDate:nil cardHolder:nil];
    pd.token.lastFourDigits = @"7890";
    pd.payerCost = nil;//[[PayerCost alloc] initWithInstallments:3 installmentRate:10 labels:nil minAllowedAmount:10 maxAllowedAmount:200 recommendedMessage:@"sarsa" installmentAmount:100 totalAmount:200];
     
    pd.issuer = nil;//[[Issuer alloc] init];
    pd.issuer._id = [NSNumber numberWithInt:200];
    
    
    //[[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:pd navigationController:self.navigationController paymentResult:nil] start];

    
}



- (void)skipReviewAndConfirm {
    
    FlowPreference *fp = [[FlowPreference alloc] init];
    [fp disableReviewAndConfirmScreen];
    [MercadoPagoCheckout setFlowPreference:fp];
    
    [MainExamplesViewController setPaymentDataCallback];
    
    //[[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:nil navigationController:self.navigationController paymentResult:nil] start];

}

-(void)startCardForm {

    //Empty
}

- (void)showCongrats {
    
    PaymentMethod *pm = [[PaymentMethod alloc] init];
    pm._id = @"debvisa";
    pm.paymentTypeId = @"debit_card";
    //pm.name = @"visa";

    PaymentData *pd = [[PaymentData alloc] init];
    pd.paymentMethod = pm;
    
    pd.token = [[Token alloc] initWith_id:@"id" publicKey:@"pk" cardId:@"" luhnValidation:nil status:nil usedDate:nil cardNumberLength:nil creationDate:nil lastFourDigits:nil firstSixDigit:@"123456" securityCodeLength:3 expirationMonth:11 expirationYear:2012 lastModifiedDate:nil dueDate:nil cardHolder:nil];
    pd.token.lastFourDigits = @"7890";
    pd.payerCost = nil;//[[PayerCost alloc] initWithInstallments:3 installmentRate:10 labels:nil minAllowedAmount:10 maxAllowedAmount:200 recommendedMessage:@"sarsa" installmentAmount:2 totalAmount:6];
    //pd.payerCost = nil;//[[PayerCost alloc] initWithInstallments:3 installmentRate:10 labels:nil minAllowedAmount:10 maxAllowedAmount:200 recommendedMessage:@"sarsa" installmentAmount:100 totalAmount:200];
    
    pd.issuer = nil;//[[Issuer alloc] init];
     PaymentResult *paymentResult = [[PaymentResult alloc] initWithStatus:@"approved" statusDetail:@"approved" paymentData:pd payerEmail:nil id:nil statementDescription:nil];
    
    //[[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:pd navigationController:self.navigationController paymentResult:paymentResult] start];

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
    
//    [MerchantServer createPayment:merchantPayment success:^(Payment *payment) {
//        NSLog(@"Payment created with id: %ld", payment._id);
//    } failure:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
}



@end
