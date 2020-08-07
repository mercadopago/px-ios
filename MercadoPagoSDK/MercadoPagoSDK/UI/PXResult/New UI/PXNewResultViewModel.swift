//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

struct ResultViewData {
    let view: UIView
    let verticalMargin: CGFloat
    let horizontalMargin: CGFloat

    init(view: UIView,
         verticalMargin: CGFloat = 0,
         horizontalMargin: CGFloat = 0) {
        self.view = view
        self.verticalMargin = verticalMargin
        self.horizontalMargin = horizontalMargin
    }
}

protocol PXNewResultViewModelInterface {
    //HEADER
    func getHeaderColor() -> UIColor
    func getHeaderTitle() -> String
    func getHeaderIcon() -> UIImage?
    func getHeaderURLIcon() -> String?
    func getHeaderBadgeImage() -> UIImage?
    func getHeaderCloseAction() -> (() -> Void)?

    //RECEIPT
    func mustShowReceipt() -> Bool
    func getReceiptId() -> String?

    //POINTS AND DISCOUNTS
    ///POINTS
    func getPoints() -> PXPoints?
    func getPointsTapAction() -> ((_ deepLink: String) -> Void)?

    ///DISCOUNTS
    func getDiscounts() -> PXDiscounts?
    func getDiscountsTapAction() -> ((_ index: Int, _ deepLink: String?, _ trackId: String?) -> Void)?
    func didTapDiscount(index: Int, deepLink: String?, trackId: String?)

    ///EXPENSE SPLIT VIEW
    func getExpenseSplit() -> PXExpenseSplit?
    func getExpenseSplitTapAction() -> (() -> Void)?

    ///CROSS SELLING
    func getCrossSellingItems() -> [PXCrossSellingItem]?
    func getCrossSellingTapAction() -> ((_ deepLink: String) -> Void)?

    ////VIEW RECEIPT ACTION
    func getViewReceiptAction() -> PXRemoteAction?

    ////TOP TEXT BOX
    func getTopTextBox() -> PXText?

    ////CUSTOM ORDER
    func getCustomOrder() -> Bool?

    //INSTRUCTIONS
    func hasInstructions() -> Bool
    func getInstructionsView() -> UIView?

    //PAYMENT METHOD
    func shouldShowPaymentMethod() -> Bool
    func getPaymentData() -> PXPaymentData?
    func getAmountHelper() -> PXAmountHelper?

    //SPLIT PAYMENT METHOD
    func getSplitPaymentData() -> PXPaymentData?
    func getSplitAmountHelper() -> PXAmountHelper?

    //REJECTED BODY
    func shouldShowErrorBody() -> Bool
    func getErrorBodyView() -> UIView?

    //REMEDY
    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView?
    func getRemedyButtonAction() -> ((String?) -> Void)?
    func isPaymentResultRejectedWithRemedy() -> Bool

    //FOOTER
    func getFooterMainAction() -> PXAction?
    func getFooterSecondaryAction() -> PXAction?

    //CUSTOM VIEWS
    ///IMPORTANT
    func getImportantView() -> UIView?

    //CONSUMER CREDITS EXPECTATION VIEW
    func getCreditsExpectationView() -> UIView?

    ///TOP CUSTOM
    func getTopCustomView() -> UIView?

    ///BOTTOM CUSTOM
    func getBottomCustomView() -> UIView?

    //CALLBACKS & TRACKING
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState, String?) -> Void)
    func getTrackingProperties() -> [String: Any]
    func getTrackingPath() -> String
    func getFlowBehaviourResult() -> PXResultKey

    //BACK URL, REDIRECT URL & AUTORETURN
    func shouldAutoReturn() -> Bool
    func getBackUrl() -> URL?
    func getRedirectUrl() -> URL?
}
