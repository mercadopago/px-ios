//
//  PXCongratsPayment.swift
//  MercadoPagoSDKV4
//
//  Created by Franco Risma on 14/07/2020.
//

import Foundation

// Este va a ser el builder
//class PXCongratsData() {
//}

@objcMembers
public class PXCongratsData {
    
    var status: PXBusinessResultStatus = .APPROVED
    var closeCallback: (PaymentResult.CongratsState, String?) -> () = { state, text in
        print("congrats state \(state) and text \(text)")
    }
    var shouldShowReceipt = true
    var receiptId = "12344"
    var mainAction = PXAction(label: "MainAction") {
        print("congrats main action")
    }
    var secondaryAction = PXAction(label: "SecondAction") {
        print("congrats secondary action")
    }
    var errorMessage: String? = "Esto es un error"
    public var navigationController: UINavigationController!
    
    public init() {}
    
    
    
    // Esto no debería hacerse
    private func getErrorComponent() -> PXErrorComponent? {
        guard let labelInstruction = errorMessage else {
            return nil
        }

        let title = PXResourceProvider.getTitleForErrorBody()
        let props = PXErrorProps(title: title.toAttributedString(), message: labelInstruction.toAttributedString())

        return PXErrorComponent(props: props)
    }
}

extension PXCongratsData: PXNewResultViewModelInterface {
    func getHeaderColor() -> UIColor {
        return .gray
    }
    
    func getHeaderTitle() -> String {
        return "Title"
    }
    
    func getHeaderIcon() -> UIImage? {
        return nil
    }
    
    func getHeaderURLIcon() -> String? {
        return "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg"
    }
    
    func getHeaderBadgeImage() -> UIImage? {
        return ResourceManager.shared.getBadgeImageWith(status: status.getDescription())
    }
    
    func getHeaderCloseAction() -> (() -> Void)? {
        let action = { [weak self] in
            if let callback = self?.closeCallback {
                callback(PaymentResult.CongratsState.EXIT, nil)
            }
        }
        return action
    }
    
    func mustShowReceipt() -> Bool {
        return shouldShowReceipt
    }
    
    func getReceiptId() -> String? {
        return receiptId
    }
    
    func getPoints() -> PXPoints? {
        // TODO
        return nil
//        return pointsAndDiscounts?.points
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
        // TODO
        return nil
//        return pointsAndDiscounts?.discounts
    }
    
    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        let action: (Int, String?, String?) -> Void = { (index, deepLink, trackId) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
        }
        return action
    }
    
    func didTapDiscount(index: Int, deepLink: String?, trackId: String?) {
        PXDeepLinkManager.open(deepLink)
        PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
    }
    
    func getExpenseSplit() -> PXExpenseSplit? {
        // TODO
        return nil
//        return pointsAndDiscounts?.expenseSplit
    }
    
    func getExpenseSplitTapAction() -> (() -> Void)? {
        // TODO
//        let action: () -> Void = { [weak self] in
//            PXDeepLinkManager.open(self?.pointsAndDiscounts?.expenseSplit?.action.target)
//            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.pointsAndDiscounts?.expenseSplit?.action.target ?? ""))
//        }
//        return action
        return nil
    }
    
    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        // TODO
        return nil
//        return pointsAndDiscounts?.crossSelling
    }
    
    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }
    
    func getViewReceiptAction() -> PXRemoteAction? {
        // TODO
        return nil
//        return pointsAndDiscounts?.viewReceiptAction
    }
    
    func getTopTextBox() -> PXText? {
        // TODO
        return nil
//        return pointsAndDiscounts?.topTextBox
    }
    
    func getCustomOrder() -> Bool? {
        // TODO
        return nil
//        return pointsAndDiscounts?.customOrder
    }
    
    func hasInstructions() -> Bool {
        return false
    }

    func getInstructionsView() -> UIView? {
        return nil
    }
    
    func shouldShowPaymentMethod() -> Bool {
        #warning("logica especifica para comparar PXBusinessResultStatus con PXPaymentStatus")
        let isApproved = status.getDescription().lowercased() == PXPaymentStatus.APPROVED.rawValue.lowercased()
        return !hasInstructions() && isApproved
    }
    
    func getPaymentData() -> PXPaymentData? {
        // TODO
        return nil
//        return paymentData
    }
    
    func getAmountHelper() -> PXAmountHelper? {
        // TODO
        return nil
//        return amountHelper
    }
    
    func getSplitPaymentData() -> PXPaymentData? {
        // TODO
        return nil
//        return amountHelper.splitAccountMoney
    }
    
    func getSplitAmountHelper() -> PXAmountHelper? {
        // TODO
        return nil
//        return amountHelper
    }
    
    func shouldShowErrorBody() -> Bool {
        return getErrorComponent() != nil
    }
    
    func getErrorBodyView() -> UIView? {
        // TODO
        return nil
//        if let errorComponent = getErrorComponent() {
//            return errorComponent.render()
//        }
//        return nil
    }
    
    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        return nil
    }
    
    func getRemedyButtonAction() -> ((String?) -> Void)? {
        // TODO
        return nil
    }
    
    func isPaymentResultRejectedWithRemedy() -> Bool {
        return false
    }
    
    func getFooterMainAction() -> PXAction? {
        return mainAction
    }
    
    func getFooterSecondaryAction() -> PXAction? {
//        let linkAction = secondaryAction != nil ? businessResult.getSecondaryAction() : PXCloseLinkAction()
//        return linkAction
        // TODO
        return secondaryAction
    }
    
    func getImportantView() -> UIView? {
        // TODO
        return nil
//        return self.businessResult.getImportantCustomView()
    }
    
    func getCreditsExpectationView() -> UIView? {
        // TODO
//        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
//            let title = resultInfo.title,
//            let subtitle = resultInfo.subtitle,
//            businessResult.isApproved() {
//            return PXCreditsExpectationView(title: title, subtitle: subtitle)
//        }
        return nil
    }
    
    func getTopCustomView() -> UIView? {
        // TODO
        return nil
//        return self.businessResult.getTopCustomView()
    }
    
    func getBottomCustomView() -> UIView? {
        // TODO
        return nil
//        return self.businessResult.getBottomCustomView()
    }
    
    func setCallback(callback: @escaping (PaymentResult.CongratsState, String?) -> Void) {
        // TODO
    }
    
    func getTrackingProperties() -> [String : Any] {
        // TODO
        return ["Franco": "Franco"]
    }
    
    func getTrackingPath() -> String {
        // TODO
        return "trackingPath"
    }
    
    func getFlowBehaviourResult() -> PXResultKey {
        switch status {
        case .APPROVED:
            return .SUCCESS
        case .REJECTED:
            return .FAILURE
        case .PENDING:
            return .PENDING
        case .IN_PROGRESS:
            return .PENDING
        }
    }
        
}
