//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "ExampleUtils.h"

#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
#import "PaymentMethodPluginConfigViewController.h"
#import "PaymentPluginViewController.h"
#import "MLMyMPPXTrackListener.h"

#ifdef PX_PRIVATE_POD
    @import MercadoPagoSDKV4;
#else
    @import MercadoPagoSDK;
#endif

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
    


    // self.pref.preferenceId = @"243962506-ca09fbc6-7fa6-461d-951c-775b37d19abc";
    //Differential pricing
    // self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";
    /* self.mpCheckout = [[MercadoPagoCheckout alloc] initWithPublicKey:@"TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd"
                                                         accessToken:nil checkoutPreference:self.pref paymentData:self.paymentData paymentResult:self.paymentResult navigationController:self.navigationController]; */

//    self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";
//

    [self setCheckoutPref_CreditCardNotExcluded];
    [self setCheckoutPrefAdditionalInfo];

//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-ba2e6b8c-8b6d-4fc3-8a47-0ab241d0dba4" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

   // Para iniciar con pref cerrada
//       self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-28cbf5df-77fb-46e4-928e-5cda2023e183" preferenceId:@"138275050-fbe5d078-44a2-41b9-81dc-4005d157f046" paymentConfiguration:[self getPaymentConfiguration]];

        // Para iniciar con pref abierta
       self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-28cbf5df-77fb-46e4-928e-5cda2023e183" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];


//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd" preferenceId:@"243962506-63f1b044-c8bf-4d34-a800-f257a46628b8"];
    NSDictionary *dict = @{ @"key" : @"value"};

    [PXTracker setListener:self flowName:@"instore" flowDetails:dict];

//    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-2590709739431780-102916-f3a297acb7f392333d80ba71b736a700__LA_LD__-181794596"];
//    [self.checkoutBuilder setPrivateKeyWithKey:@"TEST-7169122440478352-062213-d23fa9fb38e4b3e94feee29864f0fae2-443064294"];
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-6519316523937252-070516-964fafa7e2c91a2c740155fcb5474280__LA_LD__-261748045"];



    // AdvancedConfig
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];
    [advancedConfig setExpressEnabled:YES];
//    [advancedConfig setProductIdWithId:@"bh31umv10flg01nmhg60"];

    PXDiscountParamsConfiguration* disca = [[PXDiscountParamsConfiguration alloc] initWithLabels:[NSArray arrayWithObjects: @"1", @"2", nil] productId:@"bh31umv10flg01nmhg60"];
    [advancedConfig setDiscountParamsConfiguration: disca];

    // Add theme to advanced config.
//    MeliTheme *meliTheme = [[MeliTheme alloc] init];
//    [advancedConfig setTheme:meliTheme];

    MPTheme *mpTheme = [[MPTheme alloc] init];
    [advancedConfig setTheme:mpTheme];

    // Add ReviewConfirm configuration to advanced config.
    [advancedConfig setReviewConfirmConfiguration: [self getReviewScreenConfiguration]];

    // Add ReviewConfirm Dynamic views configuration to advanced config.
    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    // Add ReviewConfirm Dynamic View Controller configuration to advanced config.
    TestComponent *dynamicViewControllersConfigObject = [self getReviewScreenDynamicViewControllerConfigurationObject];
    [advancedConfig setDynamicViewControllersConfiguration: [NSArray arrayWithObjects: dynamicViewControllersConfigObject, nil]];
    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    // Add PaymentResult configuration to advanced config.
    [advancedConfig setPaymentResultConfiguration: [self getPaymentResultConfiguration]];

    // Disable bank deals
    //[advancedConfig setBankDealsEnabled:NO];

    // Set advanced comnfig
    [self.checkoutBuilder setAdvancedConfigurationWithConfig:advancedConfig];

    // Enable to test one tap
//    [self.checkoutBuilder setPrivateKeyWithKey:@"TEST-1458038826212807-062020-ff9273c67bc567320eae1a07d1c2d5b5-246046416"];
    // CDP color.
    // [self.checkoutComponents setDefaultColor:[UIColor colorWithRed:0.49 green:0.17 blue:0.55 alpha:1.0]];

    // [self.mpCheckout discountNotAvailable];



    // [self.mpCheckout setDiscount:discount withCampaign:campaign];

    // CDP color.
    //[self.mpCheckout setDefaultColor:[UIColor colorWithRed:0.49 green:0.17 blue:0.55 alpha:1.0]];

    //[self setHooks];
    
    //[self setPaymentMethodPlugins];

    //[self setPaymentPlugin];

    // [self.mpCheckout discountNotAvailable];

    [self.checkoutBuilder setLanguage:@"es"];

    // Add custom translation objc-compatible example.

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyTotal_to_pay_onetap withTranslation:@"Total row en onetap"];

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button withTranslation:@"Enviar dinero"];

    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button_progress withTranslation:@"Enviado dinero"];

    MercadoPagoCheckout *mpCheckout = [[MercadoPagoCheckout alloc] initWithBuilder:self.checkoutBuilder];

    //[mpCheckout startWithLazyInitProtocol:self];
    [mpCheckout startWithLazyInitProtocol:self];
}

// ReviewConfirm
-(PXReviewConfirmConfiguration *)getReviewScreenConfiguration {
    PXReviewConfirmConfiguration *config = [TestComponent getReviewConfirmConfiguration];
    return config;
}

// ReviewConfirm Dynamic Views Configuration Object
-(TestComponent *)getReviewScreenDynamicViewsConfigurationObject {
    TestComponent *config = [TestComponent getReviewConfirmDynamicViewsConfiguration];
    return config;
}

// ReviewConfirm Dynamic View Controller Configuration Object
-(TestComponent *)getReviewScreenDynamicViewControllerConfigurationObject {
    TestComponent *config = [TestComponent getReviewConfirmDynamicViewControllerConfiguration];
    return config;
}


// PaymentResult
-(PXPaymentResultConfiguration *)getPaymentResultConfiguration {
    PXPaymentResultConfiguration *config = [TestComponent getPaymentResultConfiguration];
    return config;
}

// Procesadora
-(PXPaymentConfiguration *)getPaymentConfiguration {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];
    PaymentPluginViewController *paymentProcessorPlugin = [storyboard instantiateViewControllerWithIdentifier:@"paymentPlugin"];
    self.paymentConfig = [[PXPaymentConfiguration alloc] initWithSplitPaymentProcessor:paymentProcessorPlugin];
    [self addPaymentMethodPluginToPaymentConfig];
    [self addCharges];
    return self.paymentConfig;
}

-(void)addPaymentMethodPluginToPaymentConfig {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"PaymentMethodPlugins" bundle:[NSBundle mainBundle]];

    PXPaymentMethodPlugin * bitcoinPaymentMethodPlugin = [[PXPaymentMethodPlugin alloc] initWithPaymentMethodPluginId:@"account_money" name:@"Bitcoin" image:[UIImage imageNamed:@"bitcoin_payment"] description:@"Estas usando dinero invertido"];

    [self.paymentConfig addPaymentMethodPluginWithPlugin:bitcoinPaymentMethodPlugin];
}

-(void)addCharges {
    NSMutableArray* chargesArray = [[NSMutableArray alloc] init];
    PXPaymentTypeChargeRule* chargeAccountMoney = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"account_money" amountCharge:20];
    PXPaymentTypeChargeRule* chargeDebit = [[PXPaymentTypeChargeRule alloc] initWithPaymentMethdodId:@"debit_card" amountCharge:8];
    [chargesArray addObject:chargeAccountMoney];
    [chargesArray addObject:chargeDebit];
    [self.paymentConfig addChargeRulesWithCharges:chargesArray];
}

-(void)setCheckoutPref_CreditCardNotExcluded {
    PXItem *item = [[PXItem alloc] initWithTitle:@"title" quantity:1 unitPrice:3500.0];

    NSArray *items = [NSArray arrayWithObjects:item, nil];

    self.pref = [[PXCheckoutPreference alloc] initWithSiteId:@"MLA" payerEmail:@"sara@gmail.com" items:items];
//    [self.pref addExcludedPaymentType:@"ticket"];
}

-(void)setCheckoutPrefAdditionalInfo {
    // Example SP support for custom additional info.
    self.pref.additionalInfo = @"{\"px_summary\":{\"title\":\"Recarga Claro\",\"image_url\":\"https://www.rondachile.cl/wordpress/wp-content/uploads/2018/03/Logo-Claro-1.jpg\",\"subtitle\":\"Celular 1159199234\",\"purpose\":\"Tu recarga\"}}";
}

-(void)setCheckoutPref_WithId {
    self.pref = [[PXCheckoutPreference alloc] initWithPreferenceId: @"242624092-2a26fccd-14dd-4456-9161-5f2c44532f1d"];
}


-(IBAction)startCardManager:(id)sender  {}

- (void)didFinishWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    [checkout startWithNavigationController:self.navigationController lifeCycleProtocol:self];
}

-(void)failureWithCheckout:(MercadoPagoCheckout * _Nonnull)checkout {
    NSLog(@"PXLog - LazyInit - failureWithCheckout");
}

-(void (^ _Nullable)(void))cancelCheckout {
    return ^ {
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void (^)(id<PXResult> _Nullable))finishCheckout {
    return nil;
}

-(void (^)(void))changePaymentMethodTapped {
    return nil;
}

- (void)trackEventWithScreenName:(NSString * _Nullable)screenName action:(NSString * _Null_unspecified)action result:(NSString * _Nullable)result extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track event
}

- (void)trackScreenWithScreenName:(NSString * _Nonnull)screenName extraParams:(NSDictionary<NSString *,id> * _Nullable)extraParams {
    // Track screen
}

@end
