//
//  CongratsUtils.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Franco Risma on 14/08/2020.
//  Copyright © 2020 MercadoPago. All rights reserved.
//

#import "CongratsUtils.h"

@implementation CongratsUtils

+(PXPoints *)points {
    return [[PXPoints alloc] initWithProgress:[[PXPointsProgress alloc] initWithPercentage:0.85 levelColor:@"#4063EA" levelNumber:4] title:@"Ud ganó 2.000 puntos" action:[[PXRemoteAction alloc] initWithLabel:@"Ver mis beneficios" target:@"meli://loyalty/webview?url=https%3A%2F%2Fwww.mercadolivre.com.br%2Fmercado-pontos%2Fv2%2Fhub%23origin%3Dcongrats"]];
}

+(PXDiscounts *)discount {
    return [[PXDiscounts alloc] initWithTitle: @"Descuentos por tu nivel" subtitle:@"" discountsAction:[[PXRemoteAction alloc] initWithLabel:@"Ver todos los descuentos" target:@"mercadopago://discount_center_payers/list#from=/px/congrats"] downloadAction:[[PXDownloadAction alloc] initWithTitle: @"Exclusivo con la app de Mercado Libre" action: [[PXRemoteAction alloc] initWithLabel: @"Descargar" target:@"https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml"]] items:@[[[PXDiscountsItem alloc] initWithIcon:@"https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg" title:@"Hasta" subtitle:@"20 % OFF" target:@"mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats" campaingId:@"1018483"]] touchpoint:nil];
}

+(NSArray<PXCrossSellingItem*>*)crossSelling {
    return @[[[PXCrossSellingItem alloc] initWithTitle:@"Gane 200 pesos por sus pagos diarios" icon:@"https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR" contentId:@"cross_selling_mgm_ml" action: [[PXRemoteAction alloc] initWithLabel: @"Invita a más amigos a usar la aplicación" target: @"meli://invite/wallet"]]];
}

+(PXExpenseSplit *)expenseSplit {
    return [[PXExpenseSplit alloc] initWithTitle:[[PXText alloc] initWithMessage:@"Expense message" backgroundColor:nil textColor:nil weight:nil] action:[[PXRemoteAction alloc] initWithLabel:@"Expense action" target:nil] imageUrl:@"meli://invite/wallet"];
}

+(PXCongratsPaymentInfo *)paymentInfo {
    return [[PXCongratsPaymentInfo alloc] initWithPaidAmount:@"$ 100" rawAmount:@"$ 1000" paymentMethodName:@"visa" paymentMethodLastFourDigits:@"1234" paymentMethodDescription:nil paymentMethodIconURL:[CongratsUtils paymentIconURL] paymentMethodType:PXPaymentOBJCCREDIT_CARD installmentsRate:13 installmentsCount:3 installmentsAmount:@"$ 500" installmentsTotalAmount:@"$ 2500" discountName:@" 30% OFF"];
}

+(PXCongratsPaymentInfo *)splitPaymentInfo {
    return [[PXCongratsPaymentInfo alloc] initWithPaidAmount:@"$ 300" rawAmount:nil paymentMethodName:@"American Express" paymentMethodLastFourDigits:@"1234" paymentMethodDescription:nil paymentMethodIconURL:[CongratsUtils paymentIconURL] paymentMethodType:PXPaymentOBJCCREDIT_CARD installmentsRate:0 installmentsCount:0 installmentsAmount:nil installmentsTotalAmount:nil discountName:@"Split"];
}

+(PXPaymentCongratsTracking *)trackingProperties:(id<PXTrackerListener>) trackListener {
    return [[PXPaymentCongratsTracking alloc] initWithCampaingId:nil currencyId:@"ARS" paymentStatusDetail:@"The payment has been approved succesfully" totalAmount:[[NSDecimalNumber alloc] initWithInt:123] paymentId:1231231 paymentMethodId:@"account_money" trackListener:trackListener flowName:@"instore" flowDetails:nil sessionId:nil];
}

+(NSString *)paymentIconURL {
    return @"https://mobile.mercadolibre.com/remote_resources/image/px_pm_mercadopago_cc?density=xhdpi&locale=en_US";
}

@end

@implementation CongratsExample

- (id)initWithTitle:(NSString*) title andData:(PXPaymentCongrats *) data {
    self = [super init];
    if (self) {
        _title = title;
        _data = data;
    }
    return self;
}
@end
