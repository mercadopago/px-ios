//
//  PXBusinessResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MLBusinessComponents

class PXBusinessResultViewModel: NSObject, PXResultViewModelInterface {

    let businessResult: PXBusinessResult
    let pointsAndDiscounts: PXPointsAndDiscounts?
    let paymentData: PXPaymentData
    let amountHelper: PXAmountHelper
    var callback: ((PaymentResult.CongratsState) -> Void)?

    //Default Image
    private lazy var approvedIconName = "default_item_icon"
    private lazy var approvedIconBundle = ResourceManager.shared.getBundle()

    init(businessResult: PXBusinessResult, paymentData: PXPaymentData, amountHelper: PXAmountHelper, pointsAndDiscounts: PXPointsAndDiscounts?) {
        self.businessResult = businessResult
        self.paymentData = paymentData
        self.amountHelper = amountHelper
        self.pointsAndDiscounts = pointsAndDiscounts
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
        guard let firstPaymentId = businessResult.getReceiptIdList()?.first  else { return businessResult.getReceiptId() }
        return firstPaymentId
    }

    func isCallForAuth() -> Bool {
        return false
    }

    func getBadgeImage() -> UIImage? {
        return ResourceManager.shared.getBadgeImageWith(status: self.businessResult.getBusinessStatus().getDescription())
    }

    func getAttributedTitle(forNewResult: Bool = false) -> NSAttributedString {
        let title = businessResult.getTitle()
        let fontSize = forNewResult ? PXNewResultHeader.TITLE_FONT_SIZE : PXHeaderRenderer.TITLE_FONT_SIZE
        let attributes = [NSAttributedString.Key.font: Utils.getFont(size: fontSize)]
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

    func getReceiptProps() -> PXReceiptProps? {
        guard let recieptId = businessResult.getReceiptId() else {
            return nil
        }
        let date = Date()
        let receiptProps = PXReceiptProps(dateLabelString: Utils.getFormatedStringDate(date), receiptDescriptionString: "Operación #".localized + recieptId)
        return receiptProps
    }

    func buildReceiptComponent() -> PXReceiptComponent? {
        guard let props = getReceiptProps() else {
            return nil
        }
        return PXReceiptComponent(props: props)
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

// MARK: New Result View Model Interface
extension PXBusinessResultViewModel: PXNewResultViewModelInterface {
    func getHeaderColor() -> UIColor {
        return primaryResultColor()
    }

    func getHeaderTitle() -> String {
        return getAttributedTitle().string
    }

    func getHeaderIcon() -> UIImage? {
        return getHeaderDefaultIcon()
    }

    func getHeaderURLIcon() -> String? {
        return businessResult.getImageUrl()
    }

    func getHeaderBadgeImage() -> UIImage? {
        return getBadgeImage()
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        let action = { [weak self] in
            if let callback = self?.callback {
                callback(PaymentResult.CongratsState.cancel_EXIT)
            }
        }
        return action
    }

    func mustShowReceipt() -> Bool {
        return businessResult.mustShowReceipt()
    }

    func getReceiptId() -> String? {
        return businessResult.getReceiptId()
    }

    func getPoints() -> PXPoints? {
        return pointsAndDiscounts?.points
    }

    func getPointsTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapScorePath())
        }
        return action
    }

    func getDiscounts() -> PXDiscounts? {
        return pointsAndDiscounts?.discounts
    }

    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        let action: (Int, String?, String?) -> Void = { (index, deepLink, trackId) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
        }
        return action
    }

    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return pointsAndDiscounts?.crossSelling
    }

    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }

    func hasInstructions() -> Bool {
        let bodyComponent = buildBodyComponent() as? PXBodyComponent
        return bodyComponent?.hasInstructions() ?? false
    }

    func getInstructionsView() -> UIView? {
        guard let bodyComponent = buildBodyComponent() as? PXBodyComponent, bodyComponent.hasInstructions() else {
            return nil
        }
        return bodyComponent.render()
    }

    func getPaymentData() -> PXPaymentData? {
        return paymentData
    }

    func getAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func getSplitPaymentData() -> PXPaymentData? {
        return amountHelper.splitAccountMoney
    }

    func getSplitAmountHelper() -> PXAmountHelper? {
        return amountHelper
    }

    func getFooterMainAction() -> PXAction? {
        return businessResult.getMainAction()
    }

    func getFooterSecondaryAction() -> PXAction? {
        let linkAction = businessResult.getSecondaryAction() != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
        return linkAction
    }

    func getImportantView() -> UIView? {
        return self.businessResult.getImportantCustomView()
    }

    func getTopCustomView() -> UIView? {
        return self.businessResult.getTopCustomView()
    }

    func getBottomCustomView() -> UIView? {
        return self.businessResult.getBottomCustomView()
    }
}
