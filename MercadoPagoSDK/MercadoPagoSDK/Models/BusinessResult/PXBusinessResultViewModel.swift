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
    let paymentData: PXPaymentData
    let amountHelper: PXAmountHelper
    var callback: ((PaymentResult.CongratsState) -> Void)?

    //Default Image
    private lazy var approvedIconName = "default_item_icon"
    private lazy var approvedIconBundle = ResourceManager.shared.getBundle()

    init(businessResult: PXBusinessResult, paymentData: PXPaymentData, amountHelper: PXAmountHelper) {
        self.businessResult = businessResult
        self.paymentData = paymentData
        self.amountHelper = amountHelper
        super.init()
    }

    func getPaymentData() -> PXPaymentData {
        return self.paymentData
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: self.businessResult.getBusinessStatus().getDescription())
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return businessResult.getBusinessStatus().getDescription()
    }

    func getPaymentStatusDetail() -> String {
        return businessResult.getBusinessStatus().getDescription()
    }

    func getPaymentId() -> String? {
       return  businessResult.getReceiptId()
    }

    func isCallForAuth() -> Bool {
        return false
    }

    func getBadgeImage() -> UIImage? {
        return ResourceManager.shared.getBadgeImageWith(status: self.businessResult.getBusinessStatus().getDescription())
    }

    func getAttributedTitle() -> NSAttributedString {
        let title = businessResult.getTitle()
        let attributes = [NSAttributedString.Key.font: Utils.getFont(size: PXHeaderRenderer.TITLE_FONT_SIZE)]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        return attributedString
    }

    func buildHeaderComponent() -> PXHeaderComponent {
        let headerImage = getHeaderDefaultIcon()
        let headerProps = PXHeaderProps(labelText: businessResult.getSubTitle()?.toAttributedString(), title: getAttributedTitle(), backgroundColor: primaryResultColor(), productImage: headerImage, statusImage: getBadgeImage(), imageURL: businessResult.getImageUrl(), closeAction: { [weak self] in
            if let callback = self?.callback {
                callback(PaymentResult.CongratsState.cancel_EXIT)
            }
        })
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
        var pmComponents: [PXComponentizable] = []
        var helpComponent: PXComponentizable?

        if self.businessResult.mustShowPaymentMethod() {
            pmComponents = getPaymentMethodComponents()
        }

        if self.businessResult.getHelpMessage() != nil {
            helpComponent = getHelpMessageComponent()
        }

        return PXBusinessResultBodyComponent(paymentMethodComponents: pmComponents, helpMessageComponent: helpComponent, creditsExpectationView: getCreditsExpectationView())
    }

    func getCreditsExpectationView() -> PXCreditsExpectationView? {
        if let resultInfo = self.amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo, self.businessResult.isApproved() {
            let props = PXCreditsExpectationProps(title: resultInfo.title, subtitle: resultInfo.subtitle)
            return PXCreditsExpectationView(props: props)
        }
        return nil
    }

    func getHelpMessageComponent() -> PXErrorComponent? {
        guard let labelInstruction = self.businessResult.getHelpMessage() else {
            return nil
        }

        let title = PXResourceProvider.getTitleForErrorBody()
        let props = PXErrorProps(title: title.toAttributedString(), message: labelInstruction.toAttributedString())

        return PXErrorComponent(props: props)
    }

    func getPaymentMethodComponents() -> [PXPaymentMethodComponent] {
        var paymentMethodsComponents: [PXPaymentMethodComponent] = []

        if let splitAccountMoney = amountHelper.splitAccountMoney, let secondPMComponent = getPaymentMethodComponent(paymentData: splitAccountMoney) {
            paymentMethodsComponents.append(secondPMComponent)
        }

        if let firstPMComponent = getPaymentMethodComponent(paymentData: self.amountHelper.getPaymentData()) {
            paymentMethodsComponents.append(firstPMComponent)
        }

        return paymentMethodsComponents
    }

    public func getPaymentMethodComponent(paymentData: PXPaymentData) -> PXPaymentMethodComponent? {
        guard let paymentMethod = paymentData.paymentMethod else {
            return nil
        }

        let image = getPaymentMethodIcon(paymentMethod: paymentMethod)
        let currency = SiteManager.shared.getCurrency()
        var amountTitle: String = ""
        var subtitle: NSMutableAttributedString?
        if let payerCost = paymentData.payerCost {
            if payerCost.installments > 1 {
                amountTitle = String(payerCost.installments) + "x " + Utils.getAmountFormated(amount: payerCost.installmentAmount, forCurrency: currency)
                subtitle = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency, addingParenthesis: true).toAttributedString()
            } else {
                amountTitle = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency)
            }
        } else {
            // Caso account money
            if  let splitAccountMoneyAmount = paymentData.getTransactionAmountWithDiscount() {
                amountTitle = Utils.getAmountFormated(amount: splitAccountMoneyAmount ?? 0, forCurrency: currency)
            } else {
                amountTitle = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
            }
        }

        var pmDescription: String = ""
        let paymentMethodName = paymentMethod.name ?? ""

        let issuer = self.paymentData.getIssuer()
        let paymentMethodIssuerName = issuer?.name ?? ""
        var descriptionDetail: NSAttributedString?

        if paymentMethod.isCard {
            if let lastFourDigits = (self.paymentData.token?.lastFourDigits) {
                pmDescription = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
            }
            if paymentMethodIssuerName.lowercased() != paymentMethodName.lowercased() && !paymentMethodIssuerName.isEmpty {
                descriptionDetail = paymentMethodIssuerName.toAttributedString()
            }
        } else {
            pmDescription = paymentMethodName
        }

        var disclaimerText: String?
        if let statementDescription = self.businessResult.getStatementDescription() {
            disclaimerText = ("En tu estado de cuenta verás el cargo como %0".localized as NSString).replacingOccurrences(of: "%0", with: "\(statementDescription)")
        }

        let bodyProps = PXPaymentMethodProps(paymentMethodIcon: image, title: amountTitle.toAttributedString(), subtitle: subtitle, descriptionTitle: pmDescription.toAttributedString(), descriptionDetail: descriptionDetail, disclaimer: disclaimerText?.toAttributedString(), backgroundColor: .white, lightLabelColor: ThemeManager.shared.labelTintColor(), boldLabelColor: ThemeManager.shared.boldLabelTintColor())

        return PXPaymentMethodComponent(props: bodyProps)
    }

    fileprivate func getPaymentMethodIcon(paymentMethod: PXPaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  ResourceManager.shared.getImageForPaymentMethod(withDescription: paymentMethod.id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }

    func buildTopCustomView() -> UIView? {
        return self.businessResult.getTopCustomView()
    }

    func buildBottomCustomView() -> UIView? {
        return self.businessResult.getBottomCustomView()
    }

    func buildImportantCustomView() -> UIView? {
        return self.businessResult.getImportantCustomView()
    }

    func getHeaderDefaultIcon() -> UIImage? {
        if let brIcon = businessResult.getIcon() {
             return brIcon
        } else if let defaultBundle = approvedIconBundle, let defaultImage = ResourceManager.shared.getImage(approvedIconName) {
            return defaultImage
        }
        return nil
    }
}

class PXBusinessResultBodyComponent: PXComponentizable {
    var paymentMethodComponents: [PXComponentizable]
    var helpMessageComponent: PXComponentizable?
    var creditsExpectationView: UIView?

    init(paymentMethodComponents: [PXComponentizable], helpMessageComponent: PXComponentizable?, creditsExpectationView: UIView?) {
        self.paymentMethodComponents = paymentMethodComponents
        self.helpMessageComponent = helpMessageComponent
        self.creditsExpectationView = creditsExpectationView
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

        for paymentMethodComponent in paymentMethodComponents {
            let pmView = paymentMethodComponent.render()
            pmView.addSeparatorLineToTop(height: 1)
            bodyView.addSubview(pmView)
            PXLayout.put(view: pmView, onBottomOfLastViewOf: bodyView)?.isActive = true
            PXLayout.pinLeft(view: pmView).isActive = true
            PXLayout.pinRight(view: pmView).isActive = true
        }

        if let creditsView = self.creditsExpectationView {
            bodyView.addSubview(creditsView)
            PXLayout.pinLeft(view: creditsView).isActive = true
            PXLayout.pinRight(view: creditsView).isActive = true
            PXLayout.put(view: creditsView, onBottomOfLastViewOf: bodyView)?.isActive = true
        }

        PXLayout.pinFirstSubviewToTop(view: bodyView)?.isActive = true
        PXLayout.pinLastSubviewToBottom(view: bodyView)?.isActive = true
        return bodyView
    }
}
