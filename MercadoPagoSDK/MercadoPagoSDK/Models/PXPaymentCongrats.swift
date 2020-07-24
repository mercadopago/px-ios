//
//  PXPaymentCongrats.swift
//  MercadoPagoSDK
//
//  Created by Franco Risma on 23/07/2020.
//

import Foundation

/**
This class holds all the information a congrats' view needs to consume (specified at `PXNewResultViewModelInterface`).
This also acts as an entry point for congrats withouth having to go through the entire checkout flow.
*/
@objcMembers
public final class PXPaymentCongrats: NSObject {
    
    // Header
    private var status: PXBusinessResultStatus = .REJECTED
    // This field is ment to be used only by Checkout
    private var headerColor: UIColor?
    private var headerTitle: String = ""
    private var headerImage: UIImage?
    private var headerURL: String?
    // This field is ment to be used only by Checkout
    private var headerBadgeImage: UIImage?
    private var headerCloseAction: (() -> ())?
    
    // Receipt
    private var shouldShowReceipt: Bool = false
    private var receiptId: String?
    
    /* --- Ponints & Discounts --- */
    // Points
    private var pointsData: PXPoints?
    
    // Discounts
    private var discounts: PXDiscounts?
    
    // Expense split
    private var expenseSplit: PXExpenseSplit?
    
    // CrossSelling
    private var crossSelling: [PXCrossSellingItem]?
    
    // View Receipt action
    #warning("Investigate what is this used for")
    private var viewReceiptAction: PXRemoteAction?
    
    private var topTextBox: PXText?
    
    private var hasCustomOrder: Bool?
    /* --- Ponints & Discounts --- */
    
    // Instructions
    private var shouldShowInstructions: Bool = false
    private var instructionsView: UIView?
    
    // Footer Buttons
    private var mainAction: PXAction?
    private var secondaryAction: PXAction?
    
    // CustomViews
    private var topView: UIView?
    private var importantView: UIView?
    private var bottomView: UIView?
    
    // Remedies
    private var hasPaymentBeenRejectedWithRemedy: Bool = false
    private var remedyButtonAction: ((String?) -> ())?
    
    private var creditsExpectationView: UIView?
    
    // Tracking
    private var trackingPath: String = "" //TODO
    private var trackingValues: [String : Any] = [:] //TODO
    // This field is ment to be used only by Checkout
    private var flowBehaviourResult: PXResultKey!
    
    // Error
    private var errorBodyView: UIView?
    
    private var navigationController: UINavigationController?
    
    // MARK: API
    
    public override init() {
        super.init()
    }
}

// MARK: Setters
extension PXPaymentCongrats {
    /**
     Indicates status Success, Failure, for more info check `PXBusinessResultStatus`.
     - parameter status: the result stats
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setStatus(_ status: PXBusinessResultStatus) -> PXPaymentCongrats {
        self.status = status
        return self
    }
    
    /**
     Any color for showing in the congrats' header. This should be used ONLY internally
     - parameter color: a color
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func setHeaderColor(_ color: UIColor) -> PXPaymentCongrats {
        self.headerColor = color
        return self
    }
    
    /**
     Fills the header view with a message.
     - parameter title: some message
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setHeaderTitle(_ title: String) -> PXPaymentCongrats {
        self.headerTitle = title
        return self
    }
    
    /**
     Collector image shown in congrats' header. Can receive an `UIImage` or a `URL`.
     - parameter image: an image in `UIImage` format
     - parameter url: an `URL` for the image
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setHeaderImage(_ image: UIImage?, orURL url: String?) -> PXPaymentCongrats {
        self.headerImage = image
        self.headerURL = url
        return self
    }
    
    /**
     Collector badge image shown in congrats' header. This should be used ONLY internally
     - parameter image: an image in `UIImage` format
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func setHeaderBadgeImage(_ image: UIImage) -> PXPaymentCongrats {
        self.headerBadgeImage = image
        return self
    }
    
    /**
     Top left close button configuration.
     - parameter action: a colsure to excecute
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setHeaderCloseAction(_ action: @escaping () -> ()) -> PXPaymentCongrats {
        self.headerCloseAction = action
        return self
    }

    /**
     Defines if the receipt view should be shown, in affirmative case, the receiptId must be supplied.
     - parameter shouldShow: some message
     - parameter receiptId: some message
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func shouldShowReceipt(_ shouldShow: Bool, receiptId: String?) -> PXPaymentCongrats {
        self.shouldShowReceipt = shouldShow
        self.receiptId = receiptId
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setPointsData(percentage: Double, levelColor: String, levelNumber: Int, title: String, actionLabel: String, actionTarget: String) -> PXPaymentCongrats {
        let action = PXRemoteAction(label: actionLabel, target: actionTarget)
        self.pointsData = PXPoints(progress: PXPointsProgress(percentage: percentage, levelColor: levelColor, levelNumber: levelNumber), title: title, action: action)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setDiscountsData() -> PXPaymentCongrats {
        self.discounts = PXDiscounts(title: "Descuentos por tu nivel", subtitle: "", discountsAction: PXRemoteAction(label: "Ver todos los descuentos", target: "mercadopago://discount_center_payers/list#from=/px/congrats"), downloadAction: PXDownloadAction(title: "Exclusivo con la app de Mercado Libre", action: PXRemoteAction(label: "Descargar", target: "https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml")), items: [PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats", campaingId: "1018483"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/826105-MLA32568902631_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018457&user_level=1&mcc=4771701&distance=543968&coupon_used=false&status=FULL&store_id=30316240&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F826105-MLA32568902631_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2015%22%2C%22subtitle%22%3A%22Drogasil%22%7D%7D%5D#from=/px/congrats", campaingId: "1018457"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/761600-MLA32568902662_102019-O.jpg", title: "Hasta", subtitle: "10 % OFF", target:  "mercadopago://discount_center_payers/detail?campaign_id=1018475&user_level=1&mcc=5611201&distance=654418&coupon_used=false&status=FULL&store_id=30108872&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F761600-MLA32568902662_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22McDonald%5Cu0027s%22%7D%7D%5D#from=/px/congrats", campaingId:"1018475") ], touchpoint: nil)
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    #warning("Check if backgroundColor, textColor, weight should be customized from the outside")
    @discardableResult
    public func setExpenseSplit(_ message: String?, backgroundColor: String?, textColor: String?, weight: String?, actionLabel: String, actionTarget: String?, imageURL: String) -> PXPaymentCongrats {
        self.expenseSplit = PXExpenseSplit(title: PXText(message: message, backgroundColor: nil, textColor: nil, weight: weight), action: PXRemoteAction(label: actionLabel, target: actionTarget), imageUrl: imageURL)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setCrossSellingData() -> PXPaymentCongrats {
        self.crossSelling = [PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))]
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setViewReceiptAction(label: String, target: String) -> PXPaymentCongrats {
        self.viewReceiptAction = PXRemoteAction(label: label, target: target)
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setTopTextBox(message: String?, backgroundColor: String?, textColor: String?, weight: String?) -> PXPaymentCongrats {
        self.topTextBox = PXText(message: message, backgroundColor: backgroundColor, textColor: textColor, weight: weight)
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func shouldHaveCustomOrder(_ customOrder: Bool) -> PXPaymentCongrats {
        self.hasCustomOrder = customOrder
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func shouldShowInstructionView(_ shouldShow: Bool) -> PXPaymentCongrats {
        self.shouldShowInstructions = shouldShow
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func setInstructionView(_ view: UIView) -> PXPaymentCongrats {
        self.instructionsView = view
        return self
    }
    
        
    /**
     Top button configuration.
     - parameter label: button display text
     - parameter action: a colsure to excecute
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setMainAction(label: String, action: @escaping () -> ()) -> PXPaymentCongrats {
        self.mainAction = PXAction(label: label, action: action)
        return self
    }
    
    /**
     Bottom button configuration.
     - parameter label: button display text
     - parameter action: a colsure to excecute
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setSecondaryAction(label: String, action: @escaping () -> ()) -> PXPaymentCongrats {
        self.secondaryAction = PXAction(label: label, action: action)
        return self
    }

    /**
     Custom views to be displayed.
     - Parameters:
        - important: some `UIView`
        - top: some `UIView`
        - bottom: some `UIView`
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setCustomViews(important: UIView?, top: UIView?, bottom: UIView?) -> PXPaymentCongrats {
        self.importantView = important
        self.topView = top
        self.bottomView = bottom
        return self
    }
    
    /**
     An error view to be displayed when a failure congrats is shown
     - parameter shouldShow: a `Bool` indicating if
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func setErrorBodyView(_ view: UIView) -> PXPaymentCongrats {
        self.errorBodyView = view
        return self
    }
    
    /**
     Shows the congrats' view.
     - parameter navController: a `UINavigationController`
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func start(using navController: UINavigationController) -> PXPaymentCongrats {
        self.navigationController = navController
        let vc = PXNewResultViewController(viewModel: self, callback:{_,_ in })
        self.navigationController?.pushViewController(vc, animated: true)
        return self
    }
}

/**
 By conforming to `PXNewResultViewModelInterface` this class can be used
 as a ViewModel for `PXNewResultViewController`
 */
extension PXPaymentCongrats: PXNewResultViewModelInterface {
    // HEADER
    #warning("PXResultViewModel also sends a status description to calculate the congrats color, a solution could be to expose only to the checkout a headerColor, and let PXBusinessResult and PXResultViewModel to set it. While external integrators should not care about header color because it should be calculated by relying in status. Validate this solution")
    func getHeaderColor() -> UIColor {
        guard let color = headerColor else {
            return ResourceManager.shared.getResultColorWith(status: self.status.getDescription())
        }
        return color
    }
    
    func getHeaderTitle() -> String {
        return headerTitle
    }
    
    func getHeaderIcon() -> UIImage? {
        return headerImage
    }
    
    func getHeaderURLIcon() -> String? {
        return headerURL
    }
    
    func getHeaderBadgeImage() -> UIImage? {
        guard let image = headerBadgeImage else {
            return ResourceManager.shared.getBadgeImageWith(status: self.status.getDescription())
        }
        return image
    }
    
    func getHeaderCloseAction() -> (() -> Void)? {
        return headerCloseAction
    }
    
    //RECEIPT
    func mustShowReceipt() -> Bool {
        return shouldShowReceipt
    }
    
    func getReceiptId() -> String? {
        return receiptId
    }
    
    //POINTS AND DISCOUNTS
    ///POINTS
    func getPoints() -> PXPoints? {
        return pointsData
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
        return discounts
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
        return self.expenseSplit
    }
    
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.expenseSplit?.action.target)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapDeeplinkPath(), properties: PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.expenseSplit?.action.target ?? ""))
        }
        return action
    }
    
    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return crossSelling
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
        return viewReceiptAction
    }
    
    ////TOP TEXT BOX
    func getTopTextBox() -> PXText? {
        return topTextBox
    }
    
    ////CUSTOM ORDER
    func getCustomOrder() -> Bool? {
        return hasCustomOrder
    }
    
    //INSTRUCTIONS
    func hasInstructions() -> Bool {
        return shouldShowInstructions
    }
    
    func getInstructionsView() -> UIView? {
        return instructionsView
    }
    
    // PAYMENT METHOD
    // TODO Para que muestre el payment method, tenemos que devolver ademas paymentData
    #warning("logica especifica para comparar PXBusinessResultStatus con PXPaymentStatus")
    func shouldShowPaymentMethod() -> Bool {
        // TODO checkear comparación de este status (BusinessStatus) pero puede ser que venga por PXResultViewModel que tiene otra logica
        let isApproved = status.getDescription().lowercased() == PXPaymentStatus.APPROVED.rawValue.lowercased()
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
        return errorBodyView != nil
    }
    
    func getErrorBodyView() -> UIView? {
        return errorBodyView
    }
    
    // REMEDY
    #warning("Chequear como resolver esto donde se le pasa parametros a esta funcion para que ejecute una accion en particular. Tener en cuenta que PXBusinessResult y PXResult tienen implementaciones distintas")
    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, remedyViewProtocol: PXRemedyViewProtocol?) -> UIView? {
        // TODO
        return nil
    }
    
    func getRemedyButtonAction() -> ((String?) -> Void)? {
        return remedyButtonAction
    }
    
    func isPaymentResultRejectedWithRemedy() -> Bool {
        return self.hasPaymentBeenRejectedWithRemedy
    }
    
    // FOOTER
    func getFooterMainAction() -> PXAction? {
        return mainAction
    }
    
    func getFooterSecondaryAction() -> PXAction? {
        return secondaryAction
    }
    
    // CUSTOM VIEWS
    func getImportantView() -> UIView? {
        return importantView
    }
    
    func getCreditsExpectationView() -> UIView? {
        return creditsExpectationView
    }
    
    func getTopCustomView() -> UIView? {
        return topView
    }
    
    func getBottomCustomView() -> UIView? {
        return bottomView
    }
    
    //CALLBACKS & TRACKING
    // TODO
    func setCallback(callback: @escaping (PaymentResult.CongratsState, String?) -> Void) {
    }
    
    // TODO double check how this is used
    func getTrackingProperties() -> [String : Any] {
        return trackingValues
    }
    
    // TODO double check how this is used
    func getTrackingPath() -> String {
        return trackingPath
    }
    
    func getFlowBehaviourResult() -> PXResultKey {
        guard let result = flowBehaviourResult else {
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
        return result
    }
}
