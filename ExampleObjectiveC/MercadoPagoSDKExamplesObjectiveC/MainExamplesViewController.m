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


    // self.pref.preferenceId = @"243962506-ca09fbc6-7fa6-461d-951c-775b37d19abc";
    //Differential pricing
    // self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";
    /* self.mpCheckout = [[MercadoPagoCheckout alloc] initWithPublicKey:@"TEST-4763b824-93d7-4ca2-a7f7-93539c3ee5bd"
                                                         accessToken:nil checkoutPreference:self.pref paymentData:self.paymentData paymentResult:self.paymentResult navigationController:self.navigationController]; */

//    self.pref.preferenceId = @"99628543-518e6477-ac0d-4f4a-8097-51c2fcc00b71";
//

    [self setCheckoutPref_CreditCardNotExcluded];
    [self setCheckoutPrefAdditionalInfo];


    //PROCESADORA
    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-d1c95375-5137-4eb7-868e-da3ca8067d79" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

    //PAGO NORMAL
//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"APP_USR-c4f42ada-0fea-42a1-9b13-31e67096dcd3" preferenceId:@"272097319-a9040a88-5971-4fcd-92d5-6eeb4612abce"];

    //ACCESS TOKEN BRASIL
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-1505-092415-b89a7cdcec6cc6c3916deab0c56c7136-472129472"];

    //ACCESS TOKEN ARGENTINO
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-7092-091314-cc8f836a12b9bf78b16e77e4409ed873-470735636"];

    // AdvancedConfig
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];
    [advancedConfig setExpressEnabled:YES];
//    [advancedConfig setProductIdWithId:@"bh31umv10flg01nmhg60"];

    PXDiscountParamsConfiguration* disca = [[PXDiscountParamsConfiguration alloc] initWithLabels:[NSArray arrayWithObjects: @"1", @"2", nil] productId:@"bh31umv10flg01nmhg60"];
    [advancedConfig setDiscountParamsConfiguration: disca];

    PXTrackingConfiguration *trackingConfig = [[PXTrackingConfiguration alloc] initWithTrackListener: self flowName:@"instore" flowDetails:nil sessionId:@"3783874"];
    [self.checkoutBuilder setTrackingConfigurationWithConfig: trackingConfig];

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
//    TestComponent *dynamicViewControllersConfigObject = [self getReviewScreenDynamicViewControllerConfigurationObject];
//    [advancedConfig setDynamicViewControllersConfiguration: [NSArray arrayWithObjects: dynamicViewControllersConfigObject, nil]];
//    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

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
