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
    private var headerTitle: String = ""
    private var headerImage: UIImage?
    private var headerURL: String?
    private var headerBadgeImage: UIImage?
    
    // Receipt
    private var shouldShowReceipt: Bool = false
    private var receiptId: String?
    
    // Action Buttons
    private var mainAction: PXAction?
    private var secondaryAction: PXAction?
    #warning("TBD - This action is triggered when tap on the X button at the top left")
    private var closeAction: (() -> ())?
    
    /* --- Ponints & Discounts --- */
    // Points
    private var pointsData: PXPoints?
    
    // Discounts
    private var discounts: PXDiscounts?
    
    // CrossSelling
    private var crossSelling: [PXCrossSellingItem]?
    
    // Expense split
    private var expenseSplit: PXExpenseSplit?
    
    // View Receipt action
    #warning("Investigate what is this used for")
    private var viewReceiptAction: PXRemoteAction?
    
    private var topTextBox: PXText?
    
    private var hasCustomOrder: Bool?
    /* --- Ponints & Discounts --- */
    
    // CustomViews
    private var topView: UIView?
    private var importantView: UIView?
    private var bottomView: UIView?
    
    private var errorMessage: String?
    
    // Remedies
    private var hasPaymentBeenRejectedWithRemedy: Bool = false
    private var remedyButtonAction: ((String?) -> ())?
    
    // Instructions
    private var shouldShowInstructions: Bool = false
    private var instructionsView: UIView?
    
    private var creditsExpectationView: UIView?
    
    // Tracking
    private var trackingPath: String = "" //TODO
    private var trackingValues: [String : Any] = [:] //TODO
    
    private var navigationController: UINavigationController?
    
    // MARK: API
    
    public override init() {
        super.init()
    }

    // MARK: Private methods
    
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
    public func headerImage(_ image: UIImage?, orURL url: String?) -> PXPaymentCongrats {
        self.headerImage = image
        self.headerURL = url
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
     - ToDo: Fill this
    */
    @discardableResult
    public func addPointsData(percentage: Double, levelColor: String, levelNumber: Int, title: String, actionLabel: String, actionTarget: String) -> PXPaymentCongrats {
        let action = PXRemoteAction(label: actionLabel, target: actionTarget)
        self.pointsData = PXPoints(progress: PXPointsProgress(percentage: percentage, levelColor: levelColor, levelNumber: levelNumber), title: title, action: action)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func addDiscounts() -> PXPaymentCongrats {
        self.discounts = PXDiscounts(title: "Descuentos por tu nivel", subtitle: "", discountsAction: PXRemoteAction(label: "Ver todos los descuentos", target: "mercadopago://discount_center_payers/list#from=/px/congrats"), downloadAction: PXDownloadAction(title: "Exclusivo con la app de Mercado Libre", action: PXRemoteAction(label: "Descargar", target: "https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml")), items: [PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats", campaingId: "1018483"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/826105-MLA32568902631_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018457&user_level=1&mcc=4771701&distance=543968&coupon_used=false&status=FULL&store_id=30316240&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F826105-MLA32568902631_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2015%22%2C%22subtitle%22%3A%22Drogasil%22%7D%7D%5D#from=/px/congrats", campaingId: "1018457"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/761600-MLA32568902662_102019-O.jpg", title: "Hasta", subtitle: "10 % OFF", target:  "mercadopago://discount_center_payers/detail?campaign_id=1018475&user_level=1&mcc=5611201&distance=654418&coupon_used=false&status=FULL&store_id=30108872&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F761600-MLA32568902662_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22McDonald%5Cu0027s%22%7D%7D%5D#from=/px/congrats", campaingId:"1018475") ], touchpoint: nil)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func addCrossSelling() -> PXPaymentCongrats {
        self.crossSelling = [PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))]
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    #warning("Check if backgroundColor, textColor, weight should be customized from the outside")
    @discardableResult
    public func addExpenseSplit(_ message: String) -> PXPaymentCongrats {
        self.expenseSplit = PXExpenseSplit(title: PXText(message: message, backgroundColor: nil, textColor: nil, weight: nil), action: PXRemoteAction(label: "TBD", target: nil), imageUrl: "someImage")
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
     Custom views to be displayed.
     - Parameters:
        - important: some `UIView`
        - top: some `UIView`
        - bottom: some `UIView`
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func addViews(important: UIView?, top: UIView?, bottom: UIView?) -> PXPaymentCongrats {
        self.importantView = important
        self.topView = top
        self.bottomView = bottom
        return self
    }
    
    /**
     For a failure congrats, this is the message displayed.
     - parameter message: some error message
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func addErrorMessage(_ message: String) -> PXPaymentCongrats {
        self.errorMessage = message
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
    func getHeaderColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: self.status.getDescription())
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
        return headerBadgeImage
    }
    
    #warning("Chequear implementacion por no es la misma entre PXResultViewModel y PXBusinessResultViewModel")
    func getHeaderCloseAction() -> (() -> Void)? {
        return closeAction
    }
    
    func mustShowReceipt() -> Bool {
        return shouldShowReceipt
    }
    
    func getReceiptId() -> String? {
        return receiptId
    }
    
    func getPoints() -> PXPoints? {
        return pointsData
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
        return discounts
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
        return self.expenseSplit
    }
    
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
    
    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { (deepLink) in
            //open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(path: TrackingPaths.Events.Congrats.getSuccessTapCrossSellingPath())
        }
        return action
    }
    
    func getViewReceiptAction() -> PXRemoteAction? {
        return viewReceiptAction
    }
    
    func getTopTextBox() -> PXText? {
        return topTextBox
    }
    
    func getCustomOrder() -> Bool? {
        return hasCustomOrder
    }
    
    func hasInstructions() -> Bool {
        return shouldShowInstructions
    }
    
    func getInstructionsView() -> UIView? {
        return instructionsView
    }
    
    // Para que muestre el payment method, tenemos que devolver ademas paymentData
    func shouldShowPaymentMethod() -> Bool {
        #warning("logica especifica para comparar PXBusinessResultStatus con PXPaymentStatus")
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
    
    func shouldShowErrorBody() -> Bool {
        return getErrorComponent() != nil
    }
    
    func getErrorBodyView() -> UIView? {
        if let errorComponent = getErrorComponent() {
            return errorComponent.render()
        }
        return nil
    }
    
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
    
    func getFooterMainAction() -> PXAction? {
        return mainAction
    }
    
    func getFooterSecondaryAction() -> PXAction? {
        return secondaryAction
    }
    
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
    
    func setCallback(callback: @escaping (PaymentResult.CongratsState, String?) -> Void) {
        // TODO
    }
    
    func getTrackingProperties() -> [String : Any] {
        return trackingValues
    }
    
    func getTrackingPath() -> String {
        return trackingPath
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
