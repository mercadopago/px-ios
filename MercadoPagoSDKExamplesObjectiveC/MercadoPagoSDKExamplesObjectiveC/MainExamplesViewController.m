//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "ExampleUtils.h"
#import "CustomTableViewCell.h"
#import "SubeTableViewCell.h"
#import "DineroEnCuentaTableViewCell.h"
#import "CustomItemTableViewCell.h"
#import "FirstHookViewController.h"
#import "SecondHookViewController.h"
#import "ThirdHookViewController.h"

#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
#import "PaymentMethodPluginConfigViewController.h"
#import "PaymentPluginViewController.h"
#import "MLMyMPPXTrackListener.h"

@import MercadoPagoSDK;
@import MercadoPagoPXTrackingV4;
@import MercadoPagoServicesV4;

@implementation MainExamplesViewController

- (IBAction)checkoutFlow:(id)sender {

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    self.pref = nil;

    ///  PASO 1: SETEAR PREFERENCIAS

    // Setear ServicePreference
    // [self setServicePreference];

    ///  PASO 2: SETEAR CHECKOUTPREF, PAYMENTDATA Y PAYMENTRESULT

    // Setear una preferencia hecha a mano
    //[self setCheckoutPref_CardsNotExcluded];

    [self setCheckoutPref_WithId];

/*
    DiscountCoupon* dc = [[DiscountCoupon alloc] initWithDiscountId:123];
    
    NSNumber *externalDiscount = [NSNumber numberWithDouble:2.00];
    
    dc.name = @"Patito Off";
    dc.coupon_amount = [externalDiscount stringValue];
    dc.percent_off = @"10";
    dc.currency_id = @"ARS";
    dc.concept = @"Descuento de patito";
    dc.amountWithoutDiscount = 50;
    dc = nil;
*/
    
    [MPXTracker.sharedInstance setTrackListener:[MLMyMPPXTrackListener new]];


    // self.pref.preferenceId = @"243962506-ca09fbc6-7fa6-461d-951c-775b37d19abc";
    //Differential pricing
    // self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";
    /* self.mpCheckout = [[MercadoPagoCheckout alloc] initWithPublicKey:@"TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd"
                                                         accessToken:nil checkoutPreference:self.pref paymentData:self.paymentData paymentResult:self.paymentResult navigationController:self.navigationController]; */

    self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";

    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-c6d9b1f9-71ff-4e05-9327-3c62468a23ee" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

    // AdvancedConfig
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];
    // Set default color or theme.
    // MeliTheme *meliTheme = [[MeliTheme alloc] init];
    MPTheme *mpTheme = [[MPTheme alloc] init];
    [advancedConfig setTheme:mpTheme];

    [self.checkoutBuilder setAdvancedConfigurationWithConfig:advancedConfig];

    // CDP color.
    // [self.checkoutComponents setDefaultColor:[UIColor colorWithRed:0.49 green:0.17 blue:0.55 alpha:1.0]];

    // [self.mpCheckout discountNotAvailable];

    // PXDiscount* discount = [[PXDiscount alloc] init];


    PXDiscount* discount = [[PXDiscount alloc] initWithId:@"34295216" name:@"nada" percentOff:20 amountOff:0 couponAmount:7 currencyId:@"ARG"];
    PXCampaign* campaign = [[PXCampaign alloc] initWithId:30959 code:@"sad" name:@"Campaña" maxCouponAmount:7];
    
    // [self.mpCheckout setDiscount:discount withCampaign:campaign];
    
    NSMutableArray* chargesArray = [[NSMutableArray alloc] init];
    PXPaymentTypeChargeRule* chargeCredit = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"payment_method_plugin" amountCharge:10.5];
    PXPaymentTypeChargeRule* chargeDebit = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"debit_card" amountCharge:8];
    [chargesArray addObject:chargeCredit];
    [chargesArray addObject:chargeDebit];
    // [self.mpCheckout setChargeRulesWithChargeRules:chargesArray];

    // Setear Callback Cancel
    // [self setVoidCallback];

    // [self.mpCheckout discountNotAvailable];

    //[self.mpCheckout lazyStartWithLifecycleDelegate: self];

    self.mpCheckout = [[MercadoPagoCheckout alloc] initWithBuilder:self.checkoutBuilder];

    [self.mpCheckout startWithNavigationController:self.navigationController];
}


-(PXPaymentConfiguration *)getPaymentConfiguration {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];
    PaymentPluginViewController *paymentProcessorPlugin = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];

    self.paymentConfig = [[PXPaymentConfiguration alloc] initWithPaymentProcessor:paymentProcessorPlugin];

    [self addPaymentMethodPluginToPaymentConfig];

    return self.paymentConfig;
}


-(void)addPaymentMethodPluginToPaymentConfig {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];

    PaymentPluginViewController *makePaymentComponent = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];

    PXPaymentMethodPlugin * bitcoinPaymentMethodPlugin = [[PXPaymentMethodPlugin alloc] initWithPaymentMethodPluginId:@"account_money" name:@"Bitcoin" image:[UIImage imageNamed:@"bitcoin_payment"] description:@"Hola mundo" paymentPlugin:makePaymentComponent];

    // Payment method config plugin component.
    // PaymentMethodPluginConfigViewController *configPaymentComponent = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodConfigPlugin"];
    // [bitcoinPaymentMethodPlugin setPaymentMethodConfigWithPlugin:configPaymentComponent];

    [self.paymentConfig addPaymentMethodPluginWithPlugin:bitcoinPaymentMethodPlugin];
}

-(void)setVoidCallback {
    // Deprecated
    /* [self.mpCheckout setCallbackCancelWithCallback:^{
        NSLog(@"Se termino el flujo");
        [self.navigationController popToRootViewControllerAnimated:NO];
    }]; */
}

-(void)setCheckoutPref_CreditCardNotExcluded {
    Item *item = [[Item alloc] initWithItemId:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWithItemId:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWithPayerId:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
  //  paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", @"debit_card", nil];
  //  paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_CardsNotExcluded {
    Item *item = [[Item alloc] initWithItemId:@"itemId" title:@"item title" quantity:10 unitPrice:10 description:@"Alfajor" currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWithItemId:@"itemId2" title:@"item title 2" quantity:1 unitPrice:2.5 description:@"Sugus" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWithPayerId:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", nil];
   // paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_WithId {
    self.pref = [[CheckoutPreference alloc] initWithPreferenceId: @"242624092-2a26fccd-14dd-4456-9161-5f2c44532f1d"];
}

-(void)setPaymentResultScreenPreference {
    PaymentResultScreenPreference *resultPreference = [TestComponent getPaymentResultPreference];
    // Deprecated
    //[self.mpCheckout setPaymentResultScreenPreference:resultPreference];
}

-(void)setReviewScreenPreference {
    ReviewScreenPreference *resultPreference = [TestComponent getReviewScreenPreference];
    // Deprecated
    //[self.mpCheckout setReviewScreenPreference:resultPreference];
}

-(void)setServicePreference {
    ServicePreference * servicePreference = [[ServicePreference alloc] init];
//    NSDictionary *extraParams = @{
//                                  @"merchant_access_token" : @"mla-cards-data" };

       NSDictionary *extraParams = @{
                                   @"access_token" : @"TEST-3284996600758722-031613-bd9e7923837b50bd493d18728eb971f0__LC_LD__-243966003" };
    //    [servicePreference setCreatePaymentWithBaseURL:@"https://private-0d59c-mercadopagoexamples.apiary-mock.com" URI:@"/create_payment" additionalInfo:extraParams];
    //
    [servicePreference setGetCustomerWithBaseURL:@"https://api.mercadopago.com" URI:@"/v1/customers/261207170-jxqdmty1ClVKjU" additionalInfo:extraParams];

    // Deprecated
    // [MercadoPagoCheckout setServicePreference:servicePreference];
}

-(IBAction)startCardManager:(id)sender  {}

- (void)lazyInitDidFinish {
    NSLog(@"lazyInitDidFinish");
    [self.mpCheckout startWithNavigationController:self.navigationController];
}

- (void)lazyInitFailureWithErrorDetail:(NSString *)errorDetail {
    NSLog(@"lazyInitFailureWithErrorDetail");
    NSLog(@"%@", errorDetail);
}

@end
