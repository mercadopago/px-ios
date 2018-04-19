//
//  PXBusinessResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXBusinessResultViewModel: NSObject, PXResultViewModelInterface {

    let businessResult: PXBusinessResult
    let paymentData: PaymentData
    let amount: Double

    init(businessResult: PXBusinessResult, paymentData: PaymentData, amount: Double) {
        self.businessResult = businessResult
        self.paymentData = paymentData
        self.amount = amount
        super.init()
    }

    func getPaymentData() -> PaymentData {
        return self.paymentData
    }

    func primaryResultColor() -> UIColor {

        switch self.businessResult.status {
        case .APPROVED:
            return ThemeManager.shared.getTheme().successColor()
        case .REJECTED:
            return ThemeManager.shared.getTheme().rejectedColor()
        case .PENDING:
            return ThemeManager.shared.getTheme().warningColor()
        case .IN_PROGRESS:
            return ThemeManager.shared.getTheme().warningColor()
        }

    }

    func setCallback(callback: @escaping (PaymentResult.CongratsState) -> Void) {
        // Nothing to do
    }

    func getPaymentStatus() -> String {
        return businessResult.status.getDescription()
    }

    func getPaymentStatusDetail() -> String {
        return businessResult.status.getDescription()
    }

    func getPaymentId() -> String? {
       return  businessResult.receiptId
    }

    func isCallForAuth() -> Bool {
        return false
    }

    func getBadgeImage() -> UIImage? {
        switch self.businessResult.status {
        case .APPROVED:
            return MercadoPago.getImage("ok_badge")
        case .REJECTED:
            return MercadoPago.getImage("error_badge")
        case .PENDING:
            return MercadoPago.getImage("orange_pending_badge")
        case .IN_PROGRESS:
            return MercadoPago.getImage("orange_pending_badge")
        }
    }
    func buildHeaderComponent() -> PXHeaderComponent {
        let headerProps = PXHeaderProps(labelText: businessResult.subtitle?.toAttributedString(), title: businessResult.title.toAttributedString(), backgroundColor: primaryResultColor(), productImage: businessResult.icon, statusImage: getBadgeImage())
        return PXHeaderComponent(props: headerProps)
    }

    func buildFooterComponent() -> PXFooterComponent {
        let footerProps = PXFooterProps(buttonAction: businessResult.mainAction, linkAction: businessResult.secondaryAction)
        return PXFooterComponent(props: footerProps)
    }

    func buildReceiptComponent() -> PXReceiptComponent? {
        guard let recieptId = businessResult.receiptId else {
            return nil
        }
        let date = Date()
        let recieptProps = PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: "Número de operación ".localized + recieptId)
        return PXReceiptComponent(props: recieptProps)
    }

    func buildBodyComponent() -> PXComponentizable? {
        var pmComponent : PXComponentizable? = nil
        var helpComponent : PXComponentizable? = nil
        if self.businessResult.showPaymentMethod {
            pmComponent =  getPaymentMethodComponent()
        }
        if (self.businessResult.helpMessage != nil) {
            helpComponent = getHelpMessageComponent()
        }
        
        return PXBusinessResultBodyComponent(paymentMethodComponent: pmComponent, helpMessageComponent: helpComponent)
    }

    func getHelpMessageComponent() -> PXErrorComponent? {
        guard let labelInstruction = self.businessResult.helpMessage else {
            return nil
        }
        
        let title = PXResourceProvider.getTitleForErrorBody()
        let props = PXErrorProps(title: title.toAttributedString(), message: labelInstruction.toAttributedString())
        
        return PXErrorComponent(props: props)
    }
    public func getPaymentMethodComponent() -> PXPaymentMethodComponent {
        let pm = self.paymentData.paymentMethod!
        
        let image = getPaymentMethodIcon(paymentMethod: pm)
        let currency = MercadoPagoContext.getCurrency()
        var amountTitle = Utils.getAmountFormated(amount: self.amount, forCurrency: currency)
        var amountDetail: String?
        if let payerCost = self.paymentData.payerCost {
            if payerCost.installments > 1 {
                amountTitle = String(payerCost.installments) + "x " + Utils.getAmountFormated(amount: payerCost.installmentAmount, forCurrency: currency)
                amountDetail = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency, addingParenthesis: true)
            }
        }
        var pmDescription: String = ""
        let paymentMethodName = pm.name ?? ""
        
        let issuer = self.paymentData.getIssuer()
        let paymentMethodIssuerName = issuer?.name ?? ""
        var descriptionDetail: NSAttributedString? = nil
        
        if pm.isCard {
            if let lastFourDigits = (self.paymentData.token?.lastFourDigits) {
                pmDescription = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
            }
            if paymentMethodIssuerName.lowercased() != paymentMethodName.lowercased() && !paymentMethodIssuerName.isEmpty {
                descriptionDetail = paymentMethodIssuerName.toAttributedString()
            }
        } else {
            pmDescription = paymentMethodName
        }
        
        var disclaimerText: String? = nil
        if let statementDescription = self.businessResult.statementDescription {
            disclaimerText =  ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(statementDescription)")
        }
        
        let bodyProps = PXPaymentMethodProps(paymentMethodIcon: image, title: amountTitle.toAttributedString(), subtitle: amountDetail?.toAttributedString(), descriptionTitle: pmDescription.toAttributedString(), descriptionDetail: descriptionDetail, disclaimer: disclaimerText?.toAttributedString(), backgroundColor: ThemeManager.shared.getTheme().detailedBackgroundColor(), lightLabelColor: ThemeManager.shared.getTheme().labelTintColor(), boldLabelColor: ThemeManager.shared.getTheme().boldLabelTintColor())
        
        return PXPaymentMethodComponent(props: bodyProps)
    }
    
    fileprivate func getPaymentMethodIcon(paymentMethod: PaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PaymentTypeId.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  MercadoPago.getImageForPaymentMethod(withDescription: paymentMethod.paymentMethodId, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }
    
    func buildTopCustomComponent() -> PXCustomComponentizable? {
        return nil
    }

    func buildBottomCustomComponent() -> PXCustomComponentizable? {
        return nil
    }

}

class PXBusinessResultBodyComponent : PXComponentizable {
    var paymentMethodComponent : PXComponentizable?
    var helpMessageComponent : PXComponentizable?
    
    init(paymentMethodComponent : PXComponentizable?, helpMessageComponent : PXComponentizable?) {
        self.paymentMethodComponent = paymentMethodComponent
        self.helpMessageComponent = helpMessageComponent
    }
    func render() -> UIView {
        let bodyView = UIView()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        if let helpMessage = self.helpMessageComponent {
            let helpView = helpMessage.render()
            bodyView.addSubview(helpView)
            PXLayout.pinLeft(view: helpView).isActive = true
            PXLayout.pinRight(view: helpView).isActive = true
        }
        if let paymentMethodComponent = self.paymentMethodComponent {
            let pmView = paymentMethodComponent.render()
            bodyView.addSubview(pmView)
            PXLayout.put(view: pmView, onBottomOfLastViewOf: bodyView)?.isActive = true
            PXLayout.pinLeft(view: pmView).isActive = true
            PXLayout.pinRight(view: pmView).isActive = true
        }
        PXLayout.pinFirstSubviewToTop(view: bodyView)?.isActive = true
        PXLayout.pinLastSubviewToBottom(view: bodyView)?.isActive = true
        return bodyView
    }
    
    
}
