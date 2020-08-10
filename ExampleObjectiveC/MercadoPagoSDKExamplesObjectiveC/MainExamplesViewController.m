//
//  MainExamplesViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "MainExamplesViewController.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"
#import "PaymentPluginViewController.h"
  
@implementation MainExamplesViewController

- (IBAction)launchCongrats:(id)sender {
    PXPaymentCongrats *congratsData = [[[[[[[[[[[[[PXPaymentCongrats alloc] init]
                                                withStatus:PXBusinessResultStatusAPPROVED]
                                               withHeaderTitle: @"¡Listo! Ya le pagaste a SuperMarket"]
                                              withHeaderImage: nil orURL: @"https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg"]
                                              shouldShowReceipt: TRUE receiptId: @"123"]
                                             withMainActionWithLabel: @"Continuar" action:^{
        NSLog(@"Continuar");
    }]
                                            withSecondaryActionWithLabel: @"Tuve un problema" action:^{
        NSLog(@"Tuve un problema");
    }]
                                           withPoints: [[PXPoints alloc] initWithProgress:[[PXPointsProgress alloc] initWithPercentage:0.85 levelColor:@"#4063EA" levelNumber:4] title:@"Ud ganó 2.000 puntos" action:[[PXRemoteAction alloc] initWithLabel:@"Ver mis beneficios" target:@"meli://loyalty/webview?url=https%3A%2F%2Fwww.mercadolivre.com.br%2Fmercado-pontos%2Fv2%2Fhub%23origin%3Dcongrats"]]]
                                           withDiscounts: [[PXDiscounts alloc] initWithTitle: @"Descuentos por tu nivel" subtitle:@"" discountsAction:[[PXRemoteAction alloc] initWithLabel:@"Ver todos los descuentos" target:@"mercadopago://discount_center_payers/list#from=/px/congrats"] downloadAction:[[PXDownloadAction alloc] initWithTitle: @"Exclusivo con la app de Mercado Libre" action: [[PXRemoteAction alloc] initWithLabel: @"Descargar" target:@"https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml"]] items:@[[[PXDiscountsItem alloc] initWithIcon:@"https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg" title:@"Hasta" subtitle:@"20 % OFF" target:@"mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats" campaingId:@"1018483"]] touchpoint:nil]]
                                         withCrossSelling:@[[[PXCrossSellingItem alloc] initWithTitle:@"Gane 200 pesos por sus pagos diarios" icon:@"https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR" contentId:@"cross_selling_mgm_ml" action: [[PXRemoteAction alloc] initWithLabel: @"Invita a más amigos a usar la aplicación" target: @"meli://invite/wallet"]]]]
                                        withExpenseSplit:@"Expense" backgroundColor:@"#000000" textColor:@"#FFFFFF" weight:nil actionLabel:@"Action expense" actionTarget:nil imageURL:@"https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg"]
                                       startUsing: self.navigationController];
}

- (IBAction)checkoutFlow:(id)sender {

    //CHECKOUT PREFERENCE
    [self setCheckoutPref];
    [self setCheckoutPrefAdditionalInfo];


    //BUILDER
    //  PREF ABIERTA - Procesadora
//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-391c666d-3757-4678-9ef6-d69c4d494cd1" checkoutPreference:self.pref paymentConfiguration:[self getPaymentConfiguration]];

    //  PREF CERRADA - Procesadora
    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-391c666d-3757-4678-9ef6-d69c4d494cd1" preferenceId:@"181794596-79127f41-cf23-4aff-952e-7d8f75121084" paymentConfiguration:[self getPaymentConfiguration]];

    //  PREF CERRADA - SIN PROCESADORA
//    self.checkoutBuilder = [[MercadoPagoCheckoutBuilder alloc] initWithPublicKey:@"TEST-391c666d-3757-4678-9ef6-d69c4d494cd1" preferenceId:@"181794596-79127f41-cf23-4aff-952e-7d8f75121084"];


    //ACCESS TOKENS
    //  Brasil
//    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-1505-092415-b89a7cdcec6cc6c3916deab0c56c7136-472129472"];

    //  Argentina
    [self.checkoutBuilder setPrivateKeyWithKey:@"APP_USR-7092-091314-cc8f836a12b9bf78b16e77e4409ed873-470735636"];

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
