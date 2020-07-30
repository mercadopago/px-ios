//
//  PXPaymentCongratsViewModel.swift
//  Pods
//
//  Created by Franco Risma on 28/07/2020.
//

import Foundation

class PXPaymentCongratsViewModel {
    
    private let paymentCongrats: PXPaymentCongrats
    
    init(paymentCongrats: PXPaymentCongrats) {
        self.paymentCongrats = paymentCongrats
    }
    
    func launch() {
        let vc = PXNewResultViewController(viewModel: self, callback:{_,_ in })
        paymentCongrats.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getPMFirstString(_ string: String) -> NSAttributedString {
        let attributedTitle = NSAttributedString(string: string, attributes: PXNewCustomView.titleAttributes)
        return attributedTitle
        
    }
    
    private func getPMSecondString(_ string: String) -> NSAttributedString {
        let attributedTitle = NSAttributedString(string: string, attributes: PXNewCustomView.subtitleAttributes)
        return attributedTitle
        
    }
}

extension PXPaymentCongratsViewModel: PXNewResultViewModelInterface {
    // HEADER
    #warning("PXResultViewModel also sends a status description to calculate the congrats color, a solution could be to expose only to the checkout a headerColor, and let PXBusinessResult and PXResultViewModel to set it. While external integrators should not care about header color because it should be calculated by relying in status. Validate this solution")
    func getHeaderColor() -> UIColor {
        guard let color = paymentCongrats.headerColor else {
            return ResourceManager.shared.getResultColorWith(status: paymentCongrats.status.getDescription())
        }
        return color
    }
    
    func getHeaderTitle() -> String {
        return paymentCongrats.headerTitle
    }
    
    func getHeaderIcon() -> UIImage? {
        return paymentCongrats.headerImage
    }
    
    func getHeaderURLIcon() -> String? {
        return paymentCongrats.headerURL
    }
    
    func getHeaderBadgeImage() -> UIImage? {
        guard let image = paymentCongrats.headerBadgeImage else {
            return ResourceManager.shared.getBadgeImageWith(status: paymentCongrats.status.getDescription())
        }
        return image
    }
    
    func getHeaderCloseAction() -> (() -> Void)? {
        return paymentCongrats.headerCloseAction
    }
    
    //RECEIPT
    func mustShowReceipt() -> Bool {
        return paymentCongrats.shouldShowReceipt
    }
    
    func getReceiptId() -> String? {
        return paymentCongrats.receiptId
    }
    
    //POINTS AND DISCOUNTS
    ///POINTS
    func getPoints() -> PXPoints? {
        return paymentCongrats.points
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
        return paymentCongrats.discounts
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
        return paymentCongrats.expenseSplit
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.paymentCongrats.expenseSplit?.action.target)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.paymentCongrats.expenseSplit?.action.target ?? ""))
        }
        return action
    }
    
    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return paymentCongrats.crossSelling
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
        return paymentCongrats.viewReceiptAction
    }
    
    ////TOP TEXT BOX
    func getTopTextBox() -> PXText? {
        return paymentCongrats.topTextBox // Charlar con Mechi porque parece que ellos no van a exponer esto.
    }
    
    ////CUSTOM ORDER
    func getCustomOrder() -> Bool? {
        return paymentCongrats.hasCustomOrder
    }
    
    //INSTRUCTIONS
    func hasInstructions() -> Bool {
        return paymentCongrats.shouldShowInstructions
    }
    
    func getInstructionsView() -> UIView? {
        return paymentCongrats.instructionsView
    }
    
    // PAYMENT METHOD
    // TODO Para que muestre el payment method, tenemos que devolver ademas paymentData
    #warning("logica especifica para comparar PXBusinessResultStatus con PXPaymentStatus")
    func shouldShowPaymentMethod() -> Bool {
        // TODO checkear comparación de este status (BusinessStatus) pero puede ser que venga por PXResultViewModel que tiene otra logica
        let isApproved = paymentCongrats.status.getDescription().lowercased() == PXPaymentStatus.APPROVED.rawValue.lowercased()
        return !hasInstructions() && isApproved
    }
    
    #warning("Desacoplar payment data del VC de Congrats")
    func getPaymentData() -> PXPaymentData? {
        // TODO
        //        return paymentData
        return nil
    }
    
    // TODO refinar esto.
    // Como el Checkout va a setear directamente el paymentViewData, tenemos que chequear si hay paymentViewData, devolvemos ese, sino, hay que armarlo
    // con los datos que el integrador externo nos provea. un title, seconTitle, thirdTitle y ver si pasamos un paymentMethodTypeId para calcular el icono
    func getPaymentViewData() -> PXNewCustomViewData? {
        guard let paymentViewData = paymentCongrats.paymentViewData else {
            // This will be excecuted only for external integrators whom doesn't have access to paymentViewData
            guard let paymentInfo = paymentCongrats.paymentInfo else { return nil }
            //firstString.append(getPMFirstString("\(totalAmount)"))
            let firstString = PXNewResultUtil.applyAttributesToFirstString(paymentInfo.amount)
            
            var secondString: NSAttributedString?
            if let intermediateSecondString = PXNewResultUtil.assembleSecondString(paymentMethodName: paymentInfo.paymentMethodName, paymentMethodLastFourDigits: paymentInfo.paymentMethodLastFourDigits.truncated(), paymentTypeIdValue: paymentInfo.paymentMethodType.rawValue) {
                secondString = PXNewResultUtil.secondStringAttributed(intermediateSecondString)
            }
            
            let thirdString = (paymentInfo.paymentMethodExtraInfo != nil) ? PXNewResultUtil.thirdStringAttributed(paymentInfo.paymentMethodExtraInfo!) : nil
            let icon = ResourceManager.shared.getImageForPaymentMethod(withDescription: paymentInfo.paymentMethodType.rawValue, defaultColor: false)
            
            let data = PXNewCustomViewData(firstString: firstString, secondString: secondString, thirdString: thirdString, icon: icon, iconURL: nil, action: nil, color: nil)
            return data
        }
        return paymentViewData
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
        return paymentCongrats.errorBodyView != nil
    }
    
    func getErrorBodyView() -> UIView? {
        return paymentCongrats.errorBodyView
    }
    
    // REMEDY
    #warning("Chequear como resolver esto donde se le pasa parametros a esta funcion para que ejecute una accion en particular. Tener en cuenta que PXBusinessResult y PXResult tienen implementaciones distintas")
    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        // TODO
        return nil
    }
    
    func getRemedyButtonAction() -> ((String?) -> Void)? {
        return paymentCongrats.remedyButtonAction
    }
    
    func isPaymentResultRejectedWithRemedy() -> Bool {
        return paymentCongrats.hasPaymentBeenRejectedWithRemedy
    }
    
    // FOOTER
    func getFooterMainAction() -> PXAction? {
        return paymentCongrats.mainAction
    }
    
    func getFooterSecondaryAction() -> PXAction? {
        return paymentCongrats.secondaryAction
    }
    
    // CUSTOM VIEWS
    func getImportantView() -> UIView? {
        return paymentCongrats.importantView
    }
    
    func getCreditsExpectationView() -> UIView? {
        return paymentCongrats.creditsExpectationView
    }
    
    func getTopCustomView() -> UIView? {
        return paymentCongrats.topView
    }
    
    func getBottomCustomView() -> UIView? {
        return paymentCongrats.bottomView
    }
    
    //CALLBACKS & TRACKING
    // TODO
    func setCallback(callback: @escaping (PaymentResult.CongratsState, String?) -> Void) {
    }
    
    // TODO double check how this is used
    func getTrackingProperties() -> [String : Any] {
        return paymentCongrats.trackingValues
    }
    
    // TODO double check how this is used
    func getTrackingPath() -> String {
        return paymentCongrats.trackingPath
    }
    
    func getFlowBehaviourResult() -> PXResultKey {
        guard let result = paymentCongrats.flowBehaviourResult else {
            switch paymentCongrats.status {
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


extension String {
    func truncated() -> String {
        return String(prefix(3))
    }
}
