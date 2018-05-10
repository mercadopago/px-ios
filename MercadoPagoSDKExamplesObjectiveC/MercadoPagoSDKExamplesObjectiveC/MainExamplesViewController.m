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
@import MercadoPagoPXTracking;


@implementation MainExamplesViewController



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkoutFlow:(id)sender {

    [MercadoPagoContext setDisplayDefaultLoadingWithFlag:NO];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    self.pref = nil;
    self.paymentData = nil;
    self.paymentResult = nil;
    
    // Setear el idioma de la aplicación
    [MercadoPagoCheckout setLanguageWithLanguage:Languages_SPANISH_MEXICO];

    ///  PASO 1: SETEAR PREFERENCIAS

    // Setear ServicePreference
    //[self setServicePreference];


    //Setear flowPreference
    //[self finishFlowBeforeRYC];


    ///  PASO 2: SETEAR CHECKOUTPREF, PAYMENTDATA Y PAYMENTRESULT

    // Setear una preferencia hecha a mano
    [self setCheckoutPref_CardsNotExcluded];

    // Setear PaymentData
    ///  PASO 3: SETEAR CALLBACK

    //Setear PaymentDataCallback
    //[self setPaymentDataCallback];

    //Setear PaymentCallback

    [self setPaymentCallback];

    DiscountCoupon* dc = [[DiscountCoupon alloc] initWithDiscountId:123];
    
    NSNumber *externalDiscount = [NSNumber numberWithDouble:2.00];
    
    dc.name = @"Patito Off";
    dc.coupon_amount = [externalDiscount stringValue];
    dc.amount_off = [externalDiscount stringValue];
    dc.currency_id = @"ARS";
    dc.concept = @"Descuento de patito";
    dc.amountWithoutDiscount = 60;
    //dc = nil;
    
    self.pref.preferenceId = @"241261700-459d4126-903c-4bad-bc05-82e5f13fa7d3";

    [MPXTracker.sharedInstance setTrackListener:[MLMyMPPXTrackListener new]];

    self.pref.preferenceId = @"243966003-d0be0be0-6fd8-4769-bf2f-7f2d979655f5";
    self.mpCheckout = [[MercadoPagoCheckout alloc] initWithPublicKey:@"APP_USR-648a260d-6fd9-4ad7-9284-90f22262c18d"
    accessToken:nil
                                                  checkoutPreference:self.pref paymentData:self.paymentData paymentResult:self.paymentResult discount:dc navigationController:self.navigationController];

    
    // Set default color or theme.
//    MeliTheme *meliExampleTheme = [[MeliTheme alloc] init];
//    MPTheme *mpExampleTheme = [[MPTheme alloc] init];
//    [self.mpCheckout setTheme: meliExampleTheme];

    // CDP color.
    //[self.mpCheckout setDefaultColor:[UIColor colorWithRed:0.49 green:0.17 blue:0.55 alpha:1.0]];
    
    //[self setHooks];
    
    //[self setPaymentMethodPlugins];

    //[self setPaymentPlugin];

    // Setear PaymentResultScreenPreference
//    [self setPaymentResultScreenPreference];

    //Setear Callback Cancel
    [self setVoidCallback];

    //Setear ReviewScreenPrefernce
 //   [self setReviewScreenPreference];

    [self.mpCheckout start];
}

-(void)setHooks {

    FlowPreference *flowPref = [[FlowPreference alloc] init];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Hooks" bundle:[NSBundle mainBundle]];

    FirstHookViewController *firstHook = [storyboard instantiateViewControllerWithIdentifier:@"firstHook"];
    SecondHookViewController *secondHook = [storyboard instantiateViewControllerWithIdentifier:@"secondHook"];
    ThirdHookViewController *thirdHook = [storyboard instantiateViewControllerWithIdentifier:@"thirdHook"];

    [flowPref addHookToFlowWithHook:firstHook];
    [flowPref addHookToFlowWithHook:secondHook];
    [flowPref addHookToFlowWithHook:thirdHook];

    [MercadoPagoCheckout setFlowPreference:flowPref];
}

-(void)setPaymentMethodPlugins {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];

    PaymentPluginViewController *makePaymentComponent = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];

    PXPaymentMethodPlugin * bitcoinPaymentMethodPlugin = [[PXPaymentMethodPlugin alloc] initWithPaymentMethodPluginId:@"bitcoin_payment" name:@"Bitcoin" image:[UIImage imageNamed:@"bitcoin_payment"] description:@"" paymentPlugin:makePaymentComponent];

    // Payment method config plugin component.
    PaymentMethodPluginConfigViewController *configPaymentComponent = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodConfigPlugin"];

    [bitcoinPaymentMethodPlugin setPaymentMethodConfigWithPlugin:configPaymentComponent];

    NSMutableArray *paymentMethodPlugins = [[NSMutableArray alloc] init];
    [paymentMethodPlugins addObject:bitcoinPaymentMethodPlugin];

    //[self.mpCheckout setPaymentMethodPluginsWithPlugins:paymentMethodPlugins];

    [self.mpCheckout setPaymentPluginWithPaymentPlugin:makePaymentComponent];
}

-(void)setPaymentPlugin {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];

    PaymentPluginViewController *makePaymentComponent = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];

    [self.mpCheckout setPaymentPluginWithPaymentPlugin:makePaymentComponent];
}

-(void)setPaymentResult {
    PaymentResult *paymentResult = [[PaymentResult alloc] initWithStatus:@"rejected" statusDetail:@"cc_rejected_call_for_authorize" paymentData:self.paymentData payerEmail:@"sarasa" paymentId:@"123" statementDescription:@"sarasa"];
    self.paymentResult = paymentResult;

}

-(void) setPaymentData {
    PaymentData* paymentData = [[PaymentData alloc] init];
    paymentData.paymentMethod = [[PaymentMethod alloc] init];
    paymentData.paymentMethod.paymentMethodId = @"visa";
    paymentData.paymentMethod.paymentTypeId = @"credit_card";
    paymentData.paymentMethod.name = @"visa";
    paymentData.payerCost = [[PayerCost alloc] initWithInstallments:1 installmentRate:0 labels:nil minAllowedAmount:100 maxAllowedAmount:1000 recommendedMessage:nil installmentAmount:100 totalAmount:100];

    self.paymentData = paymentData;
}
-(void)setRyCUpdate {
    [MercadoPagoCheckout setPaymentDataCallbackWithPaymentDataCallback: ^(PaymentData *paymentData) {
        NSLog(@"%@", paymentData.paymentMethod.paymentMethodId);
        NSLog(@"%@", paymentData.token.tokenId);
        NSLog(@"%ld", paymentData.payerCost.installments);

        ReviewScreenPreference *reviewPreferenceUpdated = [[ReviewScreenPreference alloc] init];
        //[ReviewScreenPreference addCustomItemCellWithCustomCell:customCargaSube];
        //[ReviewScreenPreference addAddionalInfoCellWithCustomCell:customCargaSube];
        [self.mpCheckout setReviewScreenPreference:reviewPreferenceUpdated];
        //        UIViewController *vc = [[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:paymentData navigationController:self.navigationController] getRootViewController];
        //[self.navigationController popToRootViewControllerAnimated:NO];
    }];
}


-(void)setPaymentDataCallback {

    [MercadoPagoCheckout setPaymentDataCallbackWithPaymentDataCallback:^(PaymentData * paymentData) {
        NSLog(@"PaymentMethod: %@", paymentData.paymentMethod.paymentMethodId);
        NSLog(@"Token_id: %@", paymentData.token.tokenId);
        NSLog(@"Installemtns: %ld", paymentData.payerCost.installments);
        NSLog(@"Issuer_id: %@", paymentData.issuer.issuerId);
        self.paymentData = paymentData;
        [self setPaymentCallback];

    }];
}

-(void)setPaymentCallback {
    [MercadoPagoCheckout setPaymentCallbackWithPaymentCallback:^(Payment * payment) {
        NSLog(@"%@", payment.paymentId);
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

-(void)setVoidCallback {
    [self.mpCheckout setCallbackCancelWithCallback:^{
        NSLog(@"Se termino el flujo");
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

-(void)finishFlowBeforeRYC {
    FlowPreference *flowPreference = [[FlowPreference alloc]init];
    [flowPreference disableReviewAndConfirmScreen];
    [MercadoPagoCheckout setFlowPreference:flowPreference];

    [MercadoPagoCheckout setPaymentDataCallbackWithPaymentDataCallback:^(PaymentData * paymentData) {
        NSLog(@"PaymentMethod: %@", paymentData.paymentMethod.paymentMethodId);
        NSLog(@"Token_id: %@", paymentData.token.tokenId);
        NSLog(@"Installemtns: %ld", paymentData.payerCost.installments);
        NSLog(@"Issuer_id: %@", paymentData.issuer.issuerId);

        FlowPreference *flowPreference = [[FlowPreference alloc]init];
        [flowPreference enableReviewAndConfirmScreen];
        [MercadoPagoCheckout setFlowPreference:flowPreference];


        [self.mpCheckout start];

    }];
}

-(void)setCheckoutPref_CreditCardNotExcluded {
    Item *item = [[Item alloc] initWithItemId:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWithItemId:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWithPayerId:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item2, item2, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", @"debit_card", nil];
    paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_CardsNotExcluded {
    Item *item = [[Item alloc] initWithItemId:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:@"Alfajor" currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWithItemId:@"itemId2" title:@"item title 2" quantity:1 unitPrice:2.5 description:@"Sugus" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWithPayerId:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item, item2, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", nil];
    paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_WithId {
    self.pref = [[CheckoutPreference alloc] initWithPreferenceId: @"242624092-2a26fccd-14dd-4456-9161-5f2c44532f1d"];
}

-(void)setPaymentResultScreenPreference {
    PaymentResultScreenPreference *resultPreference = [TestComponent getPaymentResultPreference];

    [self.mpCheckout setPaymentResultScreenPreference:resultPreference];
}

-(void)setReviewScreenPreference {
    
    ReviewScreenPreference *resultPreference = [TestComponent getReviewScreenPreference];
    
    [self.mpCheckout setReviewScreenPreference:resultPreference];
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
    [PXSDKSettings enableBetaServices];

    [MercadoPagoCheckout setServicePreference:servicePreference];
}

-(IBAction)startCardManager:(id)sender  {

    NSString *customerSinTarjetas = @"{\"cards\":null,\"identification\":{\"type\":null,\"number\":null},\"id\":\"239785138-ZJ25PFw7cYGu7L\",\"last_name\":null,\"default_card\":null,\"email\":\"palazzogcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon3Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"6762\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"2222\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon2Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"6762\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"2222\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon1Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";


//    NSData *customerData = [customerCon3Tarjetas dataUsingEncoding:NSUTF8StringEncoding];
//    id customerJson = [NSJSONSerialization JSONObjectWithData:customerData options:0 error:nil];
//    Customer *customer = [Customer fromJSON:customerJson];
//
//
//    CardsAdminViewModel *viewModel = [[CardsAdminViewModel alloc]initWithCards:customer.cards extraOptionTitle:@"Opcion" confirmPromptText: @"Eliminar"];
//    CardsAdminViewController *vc = [[CardsAdminViewController alloc]initWithViewModel:viewModel callback:^(Card * card) {
//        NSLog(@"callback");
//    }];
//
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)invokeCallback:(MPCustomCell *)button {

    [[self.customCell getDelegate] invokeCallbackWithPaymentDataWithRowCallback:^(PaymentData *paymentData) {
        NSLog(@"%@", paymentData.paymentMethod.paymentMethodId);
        NSLog(@"%@", paymentData.token.tokenId);
        NSLog(@"%ld", paymentData.payerCost.installments);

        // Mostrar modal
        NSArray *currentViewControllers = self.navigationController.viewControllers;

        // Cuando retorna de modal
        ReviewScreenPreference *reviewPreferenceUpdated = [[ReviewScreenPreference alloc] init];
        [self.mpCheckout setReviewScreenPreference:reviewPreferenceUpdated];

        //        UIViewController *vc = [[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:paymentData navigationController:self.navigationController] getRootViewController];
        //
        [self.mpCheckout updateReviewAndConfirm];

    }];
}

-(void)invokeCallbackPaymentResult:(MPCustomCell *)button {

    [[self.dineroEnCuentaCell getDelegate] invokeCallbackWithPaymentResultWithRowCallback:^(PaymentResult *paymentResult) {
        NSLog(@"%@", paymentResult.status);
        [self.navigationController popToRootViewControllerAnimated:NO];
    }];
}

@end
