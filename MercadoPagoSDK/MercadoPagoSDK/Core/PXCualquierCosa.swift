//
//  PXCualquierCosa.swift
//  MercadoPagoSDK
//
//  Created by Franco Risma on 08/07/2020.
//

import UIKit
import Foundation

@objcMembers
public class PXCongratsBuilder {
    
    func setStatus() -> PXCongratsBuilder {
        return self
    }
    
}

@objcMembers
public class PXCualquierCosa: NSObject {
    
    public var navController: UINavigationController!
    
    var br : PXBusinessResult!
    var pd : PXPaymentData!
    var ah : PXAmountHelper!
    var pad : PXPointsAndDiscounts?
    
    public override init() {
        super.init()
        // PaymentModel en android (datos del pago y currency, congrats response (descuentos, crossselling)
        
        // BUSINESSPAYMENT en android
        resolveBusinessResult()
        
        resolvePaymentData()
        
        
        pad = getPointsAndDiscount()
    }
    
    func resolveBusinessResult() {
        self.br = PXBusinessResult(receiptId: "_receipt_id_", // Numero de recibo
            status: .APPROVED, // Status
            title: "_title_", // Titulo header
            subtitle: "_subtitle_", //?????
            icon: nil, // Header default icon
            mainAction: PXAction(label: "MainAction", action: { // Botones del footer
                print("FRISMA PrimaryAction")
                self.navController.popViewController(animated: true)
            }),
            secondaryAction: PXAction(label: "SecondaryAction", action: { // Botones del footer
                print("FRISMA SecondaryAction")
                self.navController.popViewController(animated: true)
            }),
            helpMessage: "_help_message_",
            showPaymentMethod: true,
            statementDescription: nil,
            imageUrl: nil, //"https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", // Imagen del collector
            topCustomView: CustomComponentText(labelText: "Top view").render(),
            bottomCustomView: CustomComponentText(labelText: "Bottom view").render(),
            paymentStatus: "approved", // El status de mas arriba sirve solo para dibujar la congrats, pero para que se muestre el recibo, tengo que poner en este campo si está aprobado o no (check enum PXPaymentStatus)
            paymentStatusDetail: "Payment Detail",
            paymentMethodId: "PaymentMethodId",
            paymentTypeId: "PaymentTypeId",
            importantView: CustomComponentText(labelText: "Important view").render())
    }
    
    func resolvePaymentData() {
        // Cuando tiene que mostrar el pago, usa este paymentData y el amount helper
        self.pd = PXPaymentData()
        // Payment data tiene que tener un paymentMethod
        self.pd.updatePaymentDataWith(paymentMethod: PXPaymentMethod(additionalInfoNeeded: nil,
                                                                     id: "master", // Con este id se obtiene la imagen chequear PaymentMethodSearch.plist para comparar nombres
            name: "Master 2020",
            paymentTypeId: "credit_card", //Check PXPaymentTypes
            status: nil,
            secureThumbnail: nil,
            thumbnail: nil,
            deferredCapture: nil,
            settings: [PXSetting(bin: nil, cardNumber: PXCardNumber(length: 3, validation: nil), securityCode: nil)],
            minAllowedAmount: nil,
            maxAllowedAmount: nil,
            accreditationTime: nil,
            merchantAccountId: nil,
            financialInstitutions: nil,
            description: nil,
            processingModes: nil))
        
        // Para que se vea en el medio de pago los ultimos 4 dígitos hay que poner el token de la tarjeta de crédito
        self.pd.updatePaymentDataWith(token: PXToken(id: "asd", publicKey: nil, cardId: "cardId", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 16, dateCreated: nil, securityCodeLength: 3, expirationMonth: 2, expirationYear: 2025, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "123456", lastFourDigits: "0987", cardholder: nil, esc: nil))
        
        // Internamente cuando va a mostrar el payment, necesita tener seteado currency
        SiteManager.shared.setCurrency(currency: PXCurrency(id: "$", description: "Pesos", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."))
        
        let preference = PXCheckoutPreference(id: "asdasd", items: [PXItem(title: "Vasos", quantity: 1, unitPrice: 30)], payer: PXPayer(email: "asd@asd.com"), paymentPreference: nil, siteId: "MLA", expirationDateTo: nil, expirationDateFrom: nil, site: nil, differentialPricing: nil, marketplace: nil, branchId: nil, collectorId: "123123123123")
        let paymentConfigServices = PXPaymentConfigurationServices() // Aca van los descuentos, revisar
        
        self.ah = PXAmountHelper(preference: preference, paymentData: pd, chargeRules: nil, paymentConfigurationService: paymentConfigServices, splitAccountMoney: nil)
    }
    
    func getPointsAndDiscount() -> PXPointsAndDiscounts? {
        let points = PXPoints(progress: PXPointsProgress(percentage: 0.85, levelColor: "#4063EA", levelNumber: 4), title: "Ud ganó 2.000 puntos", action: PXRemoteAction(label: "Ver mis beneficios", target: "meli://loyalty/webview?url=https%3A%2F%2Fwww.mercadolivre.com.br%2Fmercado-pontos%2Fv2%2Fhub%23origin%3Dcongrats"))
              let discounts = PXDiscounts(title: "Descuentos por tu nivel", subtitle: "", discountsAction: PXRemoteAction(label: "Ver todos los descuentos", target: "mercadopago://discount_center_payers/list#from=/px/congrats"), downloadAction: PXDownloadAction(title: "Exclusivo con la app de Mercado Libre", action: PXRemoteAction(label: "Descargar", target: "https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml")), items: [PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats", campaingId: "1018483"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/826105-MLA32568902631_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018457&user_level=1&mcc=4771701&distance=543968&coupon_used=false&status=FULL&store_id=30316240&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F826105-MLA32568902631_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2015%22%2C%22subtitle%22%3A%22Drogasil%22%7D%7D%5D#from=/px/congrats", campaingId: "1018457"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/761600-MLA32568902662_102019-O.jpg", title: "Hasta", subtitle: "10 % OFF", target:  "mercadopago://discount_center_payers/detail?campaign_id=1018475&user_level=1&mcc=5611201&distance=654418&coupon_used=false&status=FULL&store_id=30108872&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F761600-MLA32568902662_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22McDonald%5Cu0027s%22%7D%7D%5D#from=/px/congrats", campaingId:"1018475") ], touchpoint: nil)
              pad = PXPointsAndDiscounts(points: points,
                                         discounts: discounts,
                                         crossSelling: [PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))],
                                         viewReceiptAction: nil,
                                         topTextBox: PXText(message: "PXTopTextBox", backgroundColor: nil, textColor: nil, weight: nil),
                                         customOrder: false,
                                         expenseSplit: nil)
          
        return pad
    }
}

@objcMembers class CustomComponentText: NSObject {
    let HEIGHT: CGFloat = 80.0
    let labelText: String
    
    required init(labelText: String? = nil) {
        self.labelText = labelText ?? "Important view test. I'm a custom important view by BusinessResult."
    }
    
    func render() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let screenSize = UIScreen.main.bounds
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenSize.width).isActive = true
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
        let textLabel = UILabel()
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.text = labelText
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 80 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 90 / 100, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0).isActive = true
        return view
    }
    
}
