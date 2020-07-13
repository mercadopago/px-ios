//
//  PXCualquierCosa.swift
//  MercadoPagoSDK
//
//  Created by Franco Risma on 08/07/2020.
//

import UIKit
import Foundation

@objcMembers
public class PXCualquierCosa: NSObject {
    
    let br : PXBusinessResult!
    var pd : PXPaymentData!
    let ah : PXAmountHelper!
    let pad : PXPointsAndDiscounts?
    
    public override init() {
        // PaymentModel en android (datos del pago y currency, congrats response (descuentos, crossselling)
        
        // BUSINESSPAYMENT en android
        br = PXBusinessResult(receiptId: "_receipt_id_", // Numero de recibo
                              status: .APPROVED, // Status
                              title: "_title_", // Titulo header
                              subtitle: "_subtitle_", //?????
                              icon: nil, // ????
                              mainAction: nil,
                              secondaryAction: nil,
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
        
        // Cuando tiene que mostrar el pago, usa este paymentData y el amount helper
        pd = PXPaymentData()
        // Payment data tiene que tener un paymentMethod
        pd.updatePaymentDataWith(paymentMethod: PXPaymentMethod(additionalInfoNeeded: nil,
                                                                id: "Master", // Con este id se obtiene la imagen
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
        pd.updatePaymentDataWith(token: PXToken(id: "asd", publicKey: nil, cardId: "cardId", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 16, dateCreated: nil, securityCodeLength: 3, expirationMonth: 2, expirationYear: 2025, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "123456", lastFourDigits: "0987", cardholder: nil, esc: nil))
        
        // Internamente cuando va a mostrar el payment, necesita tener seteado currency
        SiteManager.shared.setCurrency(currency: PXCurrency(id: "$", description: "Pesos", symbol: "$", decimalPlaces: 2, decimalSeparator: ",", thousandSeparator: "."))
        
        let preference = PXCheckoutPreference(id: "asdasd", items: [PXItem(title: "Vasos", quantity: 1, unitPrice: 30)], payer: PXPayer(email: "asd@asd.com"), paymentPreference: nil, siteId: "MLA", expirationDateTo: nil, expirationDateFrom: nil, site: nil, differentialPricing: nil, marketplace: nil, branchId: nil, collectorId: "123123123123")
        let paymentConfigServices = PXPaymentConfigurationServices()
        
        ah = PXAmountHelper(preference: preference, paymentData: pd, chargeRules: nil, paymentConfigurationService: paymentConfigServices, splitAccountMoney: nil)
        pad = nil
    }
    
    func getPaymentData() {
        
    }
    
    func getPointsAndDiscount() -> PXPointsAndDiscounts? {
        return nil
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
