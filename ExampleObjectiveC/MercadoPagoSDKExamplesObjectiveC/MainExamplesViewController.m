//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "PaymentPluginViewController.h"
#import "CongratsExamplesViewController.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
  
@implementation MainExamplesViewController

- (IBAction)launchCongrats:(id)sender {
    [self.navigationController pushViewController:[[CongratsExamplesViewController alloc] init] animated:TRUE];
}

- (IBAction)checkoutFlow:(id)sender {
    // Datos basicos para iniciar el checkout
    // publicKey y preferenceId de quien recibe el pago
    NSString *publicKey = @"TEST-391c666d-3757-4678-9ef6-d69c4d494cd1";
    NSString *preferenceId = @"181794596-79127f41-cf23-4aff-952e-7d8f75121084";
    // privateKey de quien hace el pago
    NSString *privateKey = @"APP_USR-7092-091314-cc8f836a12b9bf78b16e77e4409ed873-470735636";
    
    // Una preferencia abierta es cuando se le pasa al builder un objeto PXCheckoutPreference en vez del id
    // Las preferencias abiertas solo pueden pagarse si usa PaymentPlugin
    BOOL useOpenPreference = NO;
    // Si usa PaymentPlugin el pago lo hace el integrador
    BOOL usePaymentPlugin = YES;
    
    //BUILDER
    if (useOpenPreference) {
        // Arma una preferencia abierta
        [self setCheckoutPref];
        [self setCheckoutPrefAdditionalInfo];
        if (usePaymentPlugin) {
            //  PREF ABIERTA - Procesadora
            self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:publicKey checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];
        } else {
            //  No se puede
            NSLog(@"checkoutFlow - No se puede pagar una preferencia abierta sin una procesadora");
        }
    } else {
        if (usePaymentPlugin) {
            //  PREF CERRADA - Procesadora
            self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:publicKey preferenceId:preferenceId paymentConfiguration:[self getPaymentConfiguration]];
        } else {
            //  PREF CERRADA - SIN Procesadora
            self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:publicKey preferenceId:preferenceId];
        }
    }

    //ACCESS TOKEN
    [self.checkoutBuilder setPrivateKeyWithKey:privateKey];

    //TRACKING
    PXTrackingConfiguration *trackingConfig = [[PXTrackingConfiguration alloc] initWithTrackListener: self flowName:@"instore" flowDetails:nil sessionId:@"3783874"];
    [self.checkoutBuilder setTrackingConfigurationWithConfig: trackingConfig];

    //ADVANCED CONFIG
    [self.checkoutBuilder setAdvancedConfigurationWithConfig: [self getAdvancedConfiguration]];

    //LANGUAGE CONFIG
    [self.checkoutBuilder setLanguage:@"es"];

    //CUSTOM TRANSLATIONS
    [self setCustomTranslations];

    //CREATE CHECKOUT
    MercadoPagoCheckout *mpCheckout = [[MercadoPagoCheckout alloc] initWithBuilder:self.checkoutBuilder];

    //LAZY INIT
    [mpCheckout startWithLazyInitProtocol:self];
}

-(PXAdvancedConfiguration *)getAdvancedConfiguration {
    PXAdvancedConfiguration* advancedConfig = [[PXAdvancedConfiguration alloc] init];

    //ONE TAP
    [advancedConfig setExpressEnabled:YES];
    
    //ESC
    [advancedConfig setEscEnabled:YES];

    //PRODUCT ID
    [advancedConfig setProductIdWithId:@"bh31umv10flg01nmhg60"];

    //DISCOUNT PARAMS
    PXDiscountParamsConfiguration* discountParamsConfig = [[PXDiscountParamsConfiguration alloc] initWithLabels:[NSArray arrayWithObjects: @"1", @"2", nil] productId:@"bh31umv10flg01nmhg60"];
    [advancedConfig setDiscountParamsConfiguration: discountParamsConfig];

    //THEME
//    //  mercado libre
//    [advancedConfig setTheme:[MeliTheme new]];
    //  mercado pago
    [advancedConfig setTheme:[MPTheme new]];

    //REVIEW CONFIGURATION
    //  Review screen
    [advancedConfig setReviewConfirmConfiguration: [self getReviewScreenConfiguration]];

    //  Dynamic Views
    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    //  Dynamic View Controller
//    TestComponent *dynamicViewControllersConfigObject = [self getReviewScreenDynamicViewControllerConfigurationObject];
//    [advancedConfig setDynamicViewControllersConfiguration: [NSArray arrayWithObjects: dynamicViewControllersConfigObject, nil]];
//    [advancedConfig setReviewConfirmDynamicViewsConfiguration:[self getReviewScreenDynamicViewsConfigurationObject]];

    //PAYMENT RESULT
    [advancedConfig setPaymentResultConfiguration: [self getPaymentResultConfiguration]];

    return advancedConfig;
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
    [self addCharges];
    return self.paymentConfig;
}

// Custom translations
-(void)setCustomTranslations {
    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyTotal_to_pay_onetap withTranslation:@"Total row en onetap"];
    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button withTranslation:@"Enviar dinero"];
    [self.checkoutBuilder addCustomTranslation:PXCustomTranslationKeyPay_button_progress withTranslation:@"Enviando dinero"];
}

// Payment Type charges
-(void)addCharges {
    NSMutableArray* chargesArray = [[NSMutableArray alloc] init];
    PXPaymentTypeChargeRule* chargeDebit = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"debit_card" amountCharge:8 detailModal:nil];
//    PXPaymentTypeChargeRule* chargeZeroCreditCard = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"credit_card" message:@"Ahorro con tu banco"];

    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Test charge view"
                                      message:@"This is a test account money charge with VC"
                                   preferredStyle:UIAlertControllerStyleAlert];
    PXPaymentTypeChargeRule* chargeAccountMoney = [[PXPaymentTypeChargeRule alloc] initWithPaymentTypeId:@"account_money" amountCharge:20 detailModal: controller];

    [chargesArray addObject:chargeAccountMoney];
    [chargesArray addObject:chargeDebit];
//    [chargesArray addObject:chargeZeroCreditCard];
    (void)[self.paymentConfig addChargeRulesWithCharges:chargesArray];
}

-(void)setCheckoutPref {
    PXItem *item = [[PXItem alloc] initWithTitle:@"title" quantity:1 unitPrice:3500.0];

    NSArray *items = [NSArray arrayWithObjects:item, nil];

    self.pref = [[PXCheckoutPreference alloc] initWithSiteId:@"MLA" payerEmail:@"sara@gmail.com" items:items];
    [self.pref setGatewayProcessingModes: [NSArray arrayWithObjects: @"gateway", @"aggregator", nil]];
}

-(void)setCheckoutPrefAdditionalInfo {
    // Example SP support for custom additional info.
    self.pref.additionalInfo = @"{\"px_summary\":{\"title\":\"Recarga Claro\",\"image_url\":\"https://www.rondachile.cl/wordpress/wp-content/uploads/2018/03/Logo-Claro-1.jpg\",\"subtitle\":\"Celular 1159199234\",\"purpose\":\"Tu recarga\"}, \"px_configuration\": {\"flow_id\": \"/multiplayer\"}, \"px_custom_texts\": {\"pay_button\": \"Enviar\", \"pay_button_progress\": \"Enviando...\", \"total_description\": \"Total a enviar\"}}";
}

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
