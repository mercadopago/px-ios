//
//  PXPaymentCongratsViewModel.swift
//  Pods
//
//  Created by Franco Risma on 28/07/2020.
//

import Foundation

class PXPaymentCongratsViewModel {
    
    private let paymentData: PXPaymentCongrats
    
    init(paymentData: PXPaymentCongrats) {
        self.paymentData = paymentData
    }
    
    func launch() {
        let vc = PXNewResultViewController(viewModel: self, callback:{_,_ in })
        paymentData.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PXPaymentCongratsViewModel: PXNewResultViewModelInterface {
    // HEADER
    #warning("PXResultViewModel also sends a status description to calculate the congrats color, a solution could be to expose only to the checkout a headerColor, and let PXBusinessResult and PXResultViewModel to set it. While external integrators should not care about header color because it should be calculated by relying in status. Validate this solution")
    func getHeaderColor() -> UIColor {
        guard let color = paymentData.headerColor else {
            return ResourceManager.shared.getResultColorWith(status: paymentData.status.getDescription())
        }
        return color
    }
    
    func getHeaderTitle() -> String {
        return paymentData.headerTitle
    }
    
    func getHeaderIcon() -> UIImage? {
        return paymentData.headerImage
    }
    
    func getHeaderURLIcon() -> String? {
        return paymentData.headerURL
    }
    
    func getHeaderBadgeImage() -> UIImage? {
        guard let image = paymentData.headerBadgeImage else {
            return ResourceManager.shared.getBadgeImageWith(status: paymentData.status.getDescription())
        }
        return image
    }
    
    func getHeaderCloseAction() -> (() -> Void)? {
        return paymentData.headerCloseAction
    }
    
    //RECEIPT
    func mustShowReceipt() -> Bool {
        return paymentData.shouldShowReceipt
    }
    
    func getReceiptId() -> String? {
        return paymentData.receiptId
    }
    
    //POINTS AND DISCOUNTS
    ///POINTS
    func getPoints() -> PXPoints? {
        return paymentData.pointsData
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getPointsTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapScorePath())
        }
        return action
    }
    
    ///DISCOUNTS
    func getDiscounts() -> PXDiscounts? {
        return paymentData.discounts
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        let action: (Int, String?, String?) -> Void = { (index, deepLink, trackId) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
        }
        return action
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func didTapDiscount(index: Int, deepLink: String?, trackId: String?) {
        PXDeepLinkManager.open(deepLink)
        PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
    }
    
    ///EXPENSE SPLIT VIEW
    func getExpenseSplit() -> PXExpenseSplit? {
        return paymentData.expenseSplit
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.paymentData.expenseSplit?.action.target)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.paymentData.expenseSplit?.action.target ?? ""))
        }
        return action
    }
    
    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return paymentData.crossSelling
    }
    
    ///CROSS SELLING
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }
    
    ////VIEW RECEIPT ACTION
    func getViewReceiptAction() -> PXRemoteAction? {
        return paymentData.viewReceiptAction
    }
    
    ////TOP TEXT BOX
    func getTopTextBox() -> PXText? {
        return paymentData.topTextBox
    }
    
    ////CUSTOM ORDER
    func getCustomOrder() -> Bool? {
        return paymentData.hasCustomOrder
    }
    
    //INSTRUCTIONS
    func hasInstructions() -> Bool {
        return paymentData.shouldShowInstructions
    }
    
    func getInstructionsView() -> UIView? {
        return paymentData.instructionsView
    }
    
    // PAYMENT METHOD
    // TODO Para que muestre el payment method, tenemos que devolver ademas paymentData
    #warning("logica especifica para comparar PXBusinessResultStatus con PXPaymentStatus")
    func shouldShowPaymentMethod() -> Bool {
        // TODO checkear comparación de este status (BusinessStatus) pero puede ser que venga por PXResultViewModel que tiene otra logica
        let isApproved = paymentData.status.getDescription().lowercased() == PXPaymentStatus.APPROVED.rawValue.lowercased()
        return !hasInstructions() && isApproved
    }
    
    #warning("Desacoplar payment data del VC de Congrats")
    func getPaymentData() -> PXPaymentData? {
        // TODO
        //        return paymentData
        return nil
    }
    
    #warning("Desacoplar ammount helper del VC de Congrats")
    func getAmountHelper() -> PXAmountHelper? {
        // TODO
        //        return amountHelper
        return nil
    }
    
    // SPLIT PAYMENT METHOD
    #warning("Desacoplar payment data del VC de Congrats")
    func getSplitPaymentData() -> PXPaymentData? {
        // TODO
        //        return amountHelper.splitAccountMoney
        return nil
    }
    
    #warning("Desacoplar ammount helper del VC de Congrats")
    func getSplitAmountHelper() -> PXAmountHelper? {
        // TODO
        //        return amountHelper
        return nil
    }
    
    // REJECTED BODY
    func shouldShowErrorBody() -> Bool {
        return paymentData.errorBodyView != nil
    }
    
    func getErrorBodyView() -> UIView? {
        return paymentData.errorBodyView
    }
    
    // REMEDY
    #warning("Chequear como resolver esto donde se le pasa parametros a esta funcion para que ejecute una accion en particular. Tener en cuenta que PXBusinessResult y PXResult tienen implementaciones distintas")
    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        // TODO
        return nil
    }
    
    func getRemedyButtonAction() -> ((String?) -> Void)? {
        return paymentData.remedyButtonAction
    }
    
    func isPaymentResultRejectedWithRemedy() -> Bool {
        return paymentData.hasPaymentBeenRejectedWithRemedy
    }
    
    // FOOTER
    func getFooterMainAction() -> PXAction? {
        return paymentData.mainAction
    }
    
    func getFooterSecondaryAction() -> PXAction? {
        return paymentData.secondaryAction
    }
    
    // CUSTOM VIEWS
    func getImportantView() -> UIView? {
        return paymentData.importantView
    }
    
    func getCreditsExpectationView() -> UIView? {
        return paymentData.creditsExpectationView
    }
    
    func getTopCustomView() -> UIView? {
        return paymentData.topView
    }
    
    func getBottomCustomView() -> UIView? {
        return paymentData.bottomView
    }
    
    //CALLBACKS & TRACKING
    // TODO
    func setCallback(callback: @escaping (PaymentResult.CongratsState, String?) -> Void) {
    }
    
    // TODO double check how this is used
    func getTrackingProperties() -> [String : Any] {
        return paymentData.trackingValues
    }
    
    // TODO double check how this is used
    func getTrackingPath() -> String {
        return paymentData.trackingPath
    }
    
    func getFlowBehaviourResult() -> PXResultKey {
        guard let result = paymentData.flowBehaviourResult else {
            switch paymentData.status {
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
        return result
    }
}
