//
//  PXBusinessResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

class PXBusinessResultViewModel: NSObject, PXResultViewModelInterface {
    var screenName: String { return TrackingUtil.SCREEN_NAME_PAYMENT_RESULT }
    var screenId: String { return TrackingUtil.SCREEN_ID_PAYMENT_RESULT_BUSINESS }

    func trackInfo() {
        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName, properties: [String: String]())
    }

    let businessResult: PXBusinessResult
    let paymentData: PaymentData
    let amount: Double

    //Default Image
    private lazy var approvedIconName = "default_item_icon"
    private lazy var approvedIconBundle = MercadoPago.getBundle()

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

        switch self.businessResult.getStatus() {
        case .APPROVED:
            return ThemeManager.shared.successColor()
        case .REJECTED:
            return ThemeManager.shared.rejectedColor()
        case .PENDING:
            return ThemeManager.shared.warningColor()
        case .IN_PROGRESS:
            return ThemeManager.shared.warningColor()
        }
    }

    func setCallback(callback: @escaping (PaymentResult.CongratsState) -> Void) {
    }

    func getPaymentStatus() -> String {
        return businessResult.getStatus().getDescription()
    }

    func getPaymentStatusDetail() -> String {
        return businessResult.getStatus().getDescription()
    }

    func getPaymentId() -> String? {
       return  businessResult.getReceiptId()
    }

    func isCallForAuth() -> Bool {
        return false
    }

    func getBadgeImage() -> UIImage? {
        switch self.businessResult.getStatus() {
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
        let headerImage = getHeaderIcon()
        let headerProps = PXHeaderProps(labelText: businessResult.getSubTitle()?.toAttributedString(), title: businessResult.getTitle().toAttributedString(), backgroundColor: primaryResultColor(), productImage: headerImage, statusImage: getBadgeImage())
        return PXHeaderComponent(props: headerProps)
    }

    func buildFooterComponent() -> PXFooterComponent {
        let linkAction = businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
        let footerProps = PXFooterProps(buttonAction: businessResult.getMainAction(), linkAction: linkAction)
        return PXFooterComponent(props: footerProps)
    }

    func buildReceiptComponent() -> PXReceiptComponent? {
        guard let recieptId = businessResult.getReceiptId() else {
            return nil
        }
        let date = Date()
        let recieptProps = PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: "Número de operación ".localized + recieptId)
        return PXReceiptComponent(props: recieptProps)
    }

    func buildBodyComponent() -> PXComponentizable? {
        var pmComponent: PXComponentizable? = nil
        var helpComponent: PXComponentizable? = nil
        if self.businessResult.mustShowPaymentMethod() {
            pmComponent =  getPaymentMethodComponent()
        }

        if (self.businessResult.getHelpMessage() != nil) {
            helpComponent = getHelpMessageComponent()
        }

        return PXBusinessResultBodyComponent(paymentMethodComponent: pmComponent, helpMessageComponent: helpComponent)
    }

    func getHelpMessageComponent() -> PXErrorComponent? {
        guard let labelInstruction = self.businessResult.getHelpMessage() else {
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
        if let statementDescription = self.businessResult.getStatementDescription() {
            disclaimerText =  ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(statementDescription)")
        }
      
        let bodyProps = PXPaymentMethodProps(paymentMethodIcon: image, title: amountTitle.toAttributedString(), subtitle: amountDetail?.toAttributedString(), descriptionTitle: pmDescription.toAttributedString(), descriptionDetail: descriptionDetail, disclaimer: disclaimerText?.toAttributedString(), backgroundColor: ThemeManager.shared.detailedBackgroundColor(), lightLabelColor: ThemeManager.shared.labelTintColor(), boldLabelColor: ThemeManager.shared.boldLabelTintColor())
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
        guard let view = self.businessResult.getTopCustomView() else {
            return nil
        }
        return PXCustomComponent(view: view)
    }

    func buildBottomCustomComponent() -> PXCustomComponentizable? {
        guard let view = self.businessResult.getBottomCustomView() else {
            return nil
        }
        return PXCustomComponent(view: view)
    }

    func getHeaderIcon() -> UIImage? {
        if let brImageUrl = businessResult.getImageUrl() {
            if let image =  ViewUtils.loadImageFromUrl(brImageUrl) {
                return image
            }
        } else if let brIcon = businessResult.getIcon() {
            return brIcon
        } else if let defaultBundle = approvedIconBundle, let defaultImage = MercadoPago.getImage(approvedIconName, bundle: defaultBundle) {
            return defaultImage
        }
        return nil
    }

}

class PXBusinessResultBodyComponent: PXComponentizable {
    var paymentMethodComponent: PXComponentizable?
    var helpMessageComponent: PXComponentizable?

    init(paymentMethodComponent: PXComponentizable?, helpMessageComponent: PXComponentizable?) {
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
