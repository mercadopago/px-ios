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

@import MercadoPagoSDK;


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

    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    self.pref = nil;
    self.paymentData = nil;
    self.paymentResult = nil;

    // Setear el idioma de la aplicación
    [MercadoPagoContext setLanguageWithLanguage:"es"];

    ///  PASO 1: SETEAR PREFERENCIAS

    // Setear DecorationPreference
    [self setDecorationPreference];

    // Setear ServicePreference
    [self setServicePreference];



    //Setear flowPreference
    //[self finishFlowBeforeRYC];


    ///  PASO 2: SETEAR CHECKOUTPREF, PAYMENTDATA Y PAYMENTRESULT

    // Setear una preferencia hecha a mano
    [self setCheckoutPref_WithId];

    // Setear PaymentData
    ///  PASO 3: SETEAR CALLBACK

    //Setear PaymentDataCallback
    //[self setPaymentDataCallback];

    //Setear PaymentCallback

    [self setPaymentCallback];


    DiscountCoupon* dc = [[DiscountCoupon alloc] init];
    dc._id = @"123";
    dc.name = @"Patito Off";
    dc.coupon_amount = @"30";
    dc.amount_off = @"30";
    dc.currency_id = @"ARS";
    dc.concept = @"Descuento de patito";
    dc.amount = 300;
    self.mpCheckout = [[MercadoPagoCheckout alloc] initWithPublicKey:@"APP_USR-f3f035a2-d343-4a6f-bd3b-fc3c3cb72416" checkoutPreference:self.pref paymentData:self.paymentData paymentResult:self.paymentResult discount:dc navigationController:self.navigationController];

    // Setear PaymentResultScreenPreference
    [self setPaymentResultScreenPreference];

    //Setear Callback Cancel
    [self setVoidCallback];

    //Setear ReviewScreenPrefernce
    [self setReviewScreenPreference];
    
    [self.mpCheckout start];

}

-(void)setPaymentResult {
    PaymentResult *paymentResult = [[PaymentResult alloc] initWithStatus:@"rejected" statusDetail:@"cc_rejected_call_for_authorize" paymentData:self.paymentData payerEmail:@"sarasa" id:@"123" statementDescription:@"sarasa"];
    self.paymentResult = paymentResult;

}

-(void) setPaymentData {
    PaymentData* paymentData = [[PaymentData alloc] init];
    paymentData.paymentMethod = [[PaymentMethod alloc] init];
    paymentData.paymentMethod._id = @"visa";
    paymentData.paymentMethod.paymentTypeId = @"credit_card";
    paymentData.paymentMethod.name = @"visa";
    paymentData.payerCost = [[PayerCost alloc] initWithInstallments:1 installmentRate:0 labels:nil minAllowedAmount:100 maxAllowedAmount:1000 recommendedMessage:nil installmentAmount:100 totalAmount:100];
    
    self.paymentData = paymentData;
}
-(void)setRyCUpdate {
    [MercadoPagoCheckout setPaymentDataCallbackWithPaymentDataCallback: ^(PaymentData *paymentData) {
        NSLog(@"%@", paymentData.paymentMethod._id);
        NSLog(@"%@", paymentData.token._id);
        NSLog(@"%ld", paymentData.payerCost.installments);

        ReviewScreenPreference *reviewPreferenceUpdated = [[ReviewScreenPreference alloc] init];
        [reviewPreferenceUpdated setTitleWithTitle:@"Updated"];
        //[ReviewScreenPreference addCustomItemCellWithCustomCell:customCargaSube];
        //[ReviewScreenPreference addAddionalInfoCellWithCustomCell:customCargaSube];
        [self.mpCheckout setReviewScreenPreference:reviewPreferenceUpdated];
        //        UIViewController *vc = [[[MercadoPagoCheckout alloc] initWithCheckoutPreference:self.pref paymentData:paymentData navigationController:self.navigationController] getRootViewController];
        //[self.navigationController popToRootViewControllerAnimated:NO];
    }];
}


-(void)setPaymentDataCallback {

    [MercadoPagoCheckout setPaymentDataCallbackWithPaymentDataCallback:^(PaymentData * paymentData) {
        NSLog(@"PaymentMethod: %@", paymentData.paymentMethod._id);
        NSLog(@"Token_id: %@", paymentData.token._id);
        NSLog(@"Installemtns: %ld", paymentData.payerCost.installments);
        NSLog(@"Issuer_id: %@", paymentData.issuer._id);
        self.paymentData = paymentData;
        [self setPaymentCallback];

    }];
}

-(void)setPaymentCallback {
    [MercadoPagoCheckout setPaymentCallbackWithPaymentCallback:^(Payment * payment) {
        NSLog(@"%@", payment._id);
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
        NSLog(@"PaymentMethod: %@", paymentData.paymentMethod._id);
        NSLog(@"Token_id: %@", paymentData.token._id);
        NSLog(@"Installemtns: %ld", paymentData.payerCost.installments);
        NSLog(@"Issuer_id: %@", paymentData.issuer._id);

        FlowPreference *flowPreference = [[FlowPreference alloc]init];
        [flowPreference enableReviewAndConfirmScreen];
        [MercadoPagoCheckout setFlowPreference:flowPreference];


        [self.mpCheckout start];

    }];
}

-(void)setCheckoutPref_CreditCardNotExcluded {
    Item *item = [[Item alloc] initWith_id:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWith_id:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWith_id:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item2, item2, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", @"debit_card", nil];
    paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_CardsNotExcluded {
    Item *item = [[Item alloc] initWith_id:@"itemId" title:@"item title" quantity:100 unitPrice:10 description:nil currencyId:@"ARS"];
    Item *item2 = [[Item alloc] initWith_id:@"itemId2" title:@"item title 2" quantity:2 unitPrice:2 description:@"item description" currencyId:@"ARS"];
    Payer *payer = [[Payer alloc] initWith_id:@"payerId" email:@"payer@email.com" identification:nil entityType:nil];

    NSArray *items = [NSArray arrayWithObjects:item2, item2, nil];

    PaymentPreference *paymentExclusions = [[PaymentPreference alloc] init];
    paymentExclusions.excludedPaymentTypeIds = [NSSet setWithObjects:@"atm", @"ticket", nil];
    paymentExclusions.defaultInstallments = 1;

    self.pref = [[CheckoutPreference alloc] initWithItems:items payer:payer paymentMethods:paymentExclusions];
}

-(void)setCheckoutPref_WithId {
    self.pref = [[CheckoutPreference alloc] initWith_id: @"245099733-8771f469-d68e-4863-b8cb-9402e22c6bb2"];
}

-(void)setPaymentResultScreenPreference {
    PaymentResultScreenPreference *resultPreference = [[PaymentResultScreenPreference alloc]init];
    [resultPreference setPendingTitleWithTitle:@"¡Pagaste la recarga de SUBE de $50!"];
    [resultPreference setExitButtonTitleWithTitle:@"Ir a Actividad"];
    [resultPreference setPendingContentTextWithText:@"Se acreditará en un momento"];
    [resultPreference setPendingHeaderIconWithName:@"sube" bundle:[NSBundle mainBundle]];
    [resultPreference setApprovedTitleWithTitle:@"¡Listo, recargaste el celular"];
    [resultPreference setPendingContentTitleWithTitle:@"Para acreditar tu recarga"];
    //[resultPreference disableRejectdSecondaryExitButton];
    [resultPreference setRejectedTitleWithTitle:@"No pudimos hacer la recarga"];
    [resultPreference setRejectedSubtitleWithSubtitle:@"Movistar no esta disponible ahora"];
    [resultPreference setRejectedIconSubtextWithText:@"Uppss..."];
    [resultPreference setRejectedContentTextWithText:@"Vuelve más tarde"];
    [resultPreference setRejectedContentTitleWithTitle:@"¿Qué hago?"];
    [resultPreference disableApprovedReceipt];
    //    [resultPreference disableRejectedContentTitle];
    //    [resultPreference disableRejectedContentText];
    //    [resultPreference setRejectedSecondaryExitButtonWithCallback:^(PaymentResult * paymentResult) {
    //        NSLog(@"%@", paymentResult.status);
    //    } text:@"Ir a mi activdad"];
    //    [resultPreference disablePendingContentText];
    //    [resultPreference disableChangePaymentMethodOptionButton];
    [resultPreference setPendingSecondaryExitButtonWithCallback:^(PaymentResult * paymentResult) {
        NSLog(@"%@", paymentResult.status);
        [self.navigationController popToRootViewControllerAnimated:NO];
    } text:@"Ir a mi actividad"];
    //    [resultPreference setApprovedSecondaryExitButtonWithCallback:^(PaymentResult * paymentResult) {
    //        NSLog(@"%@", paymentResult.status);
    //        [self.navigationController popToRootViewControllerAnimated:NO];
    //    } text:@"Ir a mi actividad"];



    // Celdas custom de Payment Result

    SubeTableViewCell *subeCell = [[[NSBundle mainBundle] loadNibNamed:@"SubeTableViewCell" owner:self options:nil] firstObject];
    MPCustomCell *subeCongrats = [[MPCustomCell alloc] initWithCell:subeCell];

    DineroEnCuentaTableViewCell *dineroEnCuenta = [[[NSBundle mainBundle] loadNibNamed:@"DineroEnCuentaTableViewCell" owner:self options:nil] firstObject];
    [dineroEnCuenta.button addTarget:self action:@selector(invokeCallbackPaymentResult:) forControlEvents:UIControlEventTouchUpInside];
    MPCustomCell *dineroEnCuentaCustom = [[MPCustomCell alloc] initWithCell:dineroEnCuenta];
    self.dineroEnCuentaCell = dineroEnCuentaCustom;


    DineroEnCuentaTableViewCell *header = [[[NSBundle mainBundle] loadNibNamed:@"DineroEnCuentaTableViewCell" owner:self options:nil] firstObject];
    header.label.text = @"AXION";
    MPCustomCell *subHeader = [[MPCustomCell alloc] initWithCell:header];


    [resultPreference setCustomPendingCellsWithCustomCells:[NSArray arrayWithObjects:subeCongrats, nil]];
    [resultPreference setCustomsApprovedCellWithCustomCells:[NSArray arrayWithObjects:dineroEnCuentaCustom, nil]];
    [resultPreference setCustomApprovedSubHeaderCellWithCustomCells:[NSArray arrayWithObjects:subHeader, nil]];

    [self.mpCheckout setPaymentResultScreenPreference:resultPreference];

}

-(void)setReviewScreenPreference {
    // Setear celdas custom para RyC

    CustomTableViewCell *cargaSubeCell = [[[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil] firstObject];
    cargaSubeCell.label.text = @"Carga SUBE";
    [cargaSubeCell.button setTitle:@"Cambiar" forState:UIControlStateNormal];
    [cargaSubeCell.button addTarget:self action:@selector(invokeCallback:) forControlEvents:UIControlEventTouchUpInside];

    CustomTableViewCell *cargaSubeCell2 = [[[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil] firstObject];
    cargaSubeCell2.label.text = @"Carga SUBE";
    [cargaSubeCell2.button setTitle:@"Cambiar" forState:UIControlStateNormal];
    [cargaSubeCell2.button addTarget:self action:@selector(invokeCallback:) forControlEvents:UIControlEventTouchUpInside];

    MPCustomCell *customCargaSube = [[MPCustomCell alloc] initWithCell:cargaSubeCell];
    MPCustomCell *customCargaSube2 = [[MPCustomCell alloc] initWithCell:cargaSubeCell2];
    self.customCell = customCargaSube;

    // Setear Revisa y confima Preference

    ReviewScreenPreference *reviewPreference = [[ReviewScreenPreference alloc] init];
    [reviewPreference setTitleWithTitle:@"Recarga tu SUBE"];
    [reviewPreference setConfirmButtonTextWithConfirmButtonText:@"Confirmar recarga"];
    [reviewPreference setCancelButtonTextWithCancelButtonText:@"Cancelar recarga"];
    //[ReviewScreenPreference addCustomItemCellWithCustomCell:customCargaSube];

    SummaryRow *summaryRow = [[SummaryRow alloc] initWithCustomDescription:@"Comisión BACEN" descriptionColor: UIColor.brownColor customAmount:20.0 amountColor:UIColor.redColor separatorLine:NO];

    [summaryRow disableAmount];
    
    SummaryRow *summaryRow2 = [[SummaryRow alloc] initWithCustomDescription:@"Incluye interes" descriptionColor: UIColor.grayColor customAmount:0 amountColor:UIColor.redColor separatorLine:YES];
    
    [summaryRow2 disableAmount];

    [reviewPreference setAddionalInfoCellsWithCustomCells:[NSArray arrayWithObjects:customCargaSube2, customCargaSube, nil]];

    [self.mpCheckout setReviewScreenPreference:reviewPreference];
}

-(void)setServicePreference {
    ServicePreference * servicePreference = [[ServicePreference alloc] init];
//    NSDictionary *extraParams = @{
//                                  @"merchant_access_token" : @"mla-cards-data" };
//    //    [servicePreference setCreatePaymentWithBaseURL:@"https://private-0d59c-mercadopagoexamples.apiary-mock.com" URI:@"/create_payment" additionalInfo:extraParams];
//    //
//    [servicePreference setGetCustomerWithBaseURL:@"https://www.mercadopago.com" URI:@"/checkout/examples/getCustomer" additionalInfo:extraParams];

    [MercadoPagoCheckout setServicePreference:servicePreference];
}

-(void)setDecorationPreference {
    DecorationPreference *decorationPreference = [[DecorationPreference alloc] initWithBaseColor:[UIColor fromHex:@"#CA254D"]];
    [MercadoPagoCheckout setDecorationPreference:decorationPreference];
}

-(IBAction)startCardManager:(id)sender  {

    NSString *customerSinTarjetas = @"{\"cards\":null,\"identification\":{\"type\":null,\"number\":null},\"id\":\"239785138-ZJ25PFw7cYGu7L\",\"last_name\":null,\"default_card\":null,\"email\":\"palazzogcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon3Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"6762\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"2222\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon2Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"6762\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}, {\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"2222\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";

    NSString *customerCon1Tarjetas = @"{\"cards\":[{\"expiration_year\":2017,\"issuer\":{\"id\":279,\"name\":\"Banco Galicia\"},\"last_four_digits\":\"1111\",\"date_created\":\"2017-05-23 03:00:00 +0000\",\"id\":210616405,\"payment_method\":{\"secure_thumbnail\":\"https:\/\/www.mercadopago.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"name\":\"Visa\",\"thumbnail\":\"http:\/\/img.mlstatic.com\/org-img\/MP3\/API\/logos\/visa.gif\",\"payment_type_id\":\"credit_card\",\"accreditation_time\":null,\"additional_info_needed\":\"\",\"financial_institutions\":null,\"status\":null,\"id\":\"visa\",\"settings\":null,\"max_allowed_amount\":null,\"min_allowed_amount\":0,\"deferred_capture\":null},\"expiration_month\":6,\"security_code\":{\"mode\":\"\",\"cardLocation\":\"back\",\"length\":3},\"card_holder\":{\"name\":\"IGNACIO OVIEDO\",\"identification\":{\"type\":\"DNI\",\"number\":\"36409502\"}},\"date_last_updated\":\"2017-05-23 03:00:00 +0000\",\"customer_id\":\"242465951-bE6gna32mdkmFG\",\"first_six_digits\":\"454640\"}],\"identification\":{\"type\":null,\"number\":null}\,\"id\":\"242465951-bE6gna32mdkmFG\",\"last_name\":null\,\"default_card\":null\,\"email\":\"ignaciooviedo.gcba@gmail.com\",\"date_created\":\"2017-01-30\",\"description\":null,\"first_name\":null}";


    NSData *customerData = [customerCon3Tarjetas dataUsingEncoding:NSUTF8StringEncoding];
    id customerJson = [NSJSONSerialization JSONObjectWithData:customerData options:0 error:nil];
    Customer *customer = [Customer fromJSON:customerJson];


    CardsAdminViewModel *viewModel = [[CardsAdminViewModel alloc]initWithCards:customer.cards extraOptionTitle:@"Opcion" confirmPromptText: @"Eliminar"];
    CardsAdminViewController *vc = [[CardsAdminViewController alloc]initWithViewModel:viewModel callback:^(Card * card) {
        NSLog(@"callback");
    }];

    [self.navigationController pushViewController:vc animated:YES];
}

-(void)invokeCallback:(MPCustomCell *)button {

    [[self.customCell getDelegate] invokeCallbackWithPaymentDataWithRowCallback:^(PaymentData *paymentData) {
        NSLog(@"%@", paymentData.paymentMethod._id);
        NSLog(@"%@", paymentData.token._id);
        NSLog(@"%ld", paymentData.payerCost.installments);

        // Mostrar modal
        NSArray *currentViewControllers = self.navigationController.viewControllers;

        // Cuando retorna de modal
        ReviewScreenPreference *reviewPreferenceUpdated = [[ReviewScreenPreference alloc] init];
        [reviewPreferenceUpdated setTitleWithTitle:@"Updated"];
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
