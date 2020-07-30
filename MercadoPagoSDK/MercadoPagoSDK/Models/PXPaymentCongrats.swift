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
    private(set) var status: PXBusinessResultStatus = .REJECTED
    // This field is ment to be used only by Checkout
    private(set) var headerColor: UIColor?
    private(set) var headerTitle: String = ""
    private(set) var headerImage: UIImage?
    private(set) var headerURL: String?
    // This field is ment to be used only by Checkout
    private(set) var headerBadgeImage: UIImage?
    private(set) var headerCloseAction: (() -> ())?
    
    // Receipt
    private(set) var shouldShowReceipt: Bool = false
    private(set) var receiptId: String?
    
    /* --- Points & Discounts --- */
    // Points
    private(set) var points: PXPoints?
    
    // Discounts
    private(set) var discounts: PXDiscounts?
    
    // Expense split
    private(set) var expenseSplit: PXExpenseSplit?
    
    // CrossSelling
    private(set) var crossSelling: [PXCrossSellingItem]?
    
    // View Receipt action
    private(set) var viewReceiptAction: PXRemoteAction?
    
    private(set) var topTextBox: PXText?
    
    private(set) var hasCustomOrder: Bool?
    /* --- Ponints & Discounts --- */
    
    // Instructions
    private(set) var shouldShowInstructions: Bool = false
    private(set) var instructionsView: UIView?
    
    // Footer Buttons
    private(set) var mainAction: PXAction?
    private(set) var secondaryAction: PXAction?
    
    // CustomViews
    private(set) var topView: UIView?
    private(set) var importantView: UIView?
    private(set) var bottomView: UIView?
    
    // Remedies
    private(set) var hasPaymentBeenRejectedWithRemedy: Bool = false
    private(set) var remedyButtonAction: ((String?) -> ())?
    
    private(set) var creditsExpectationView: UIView?
    
    // Payment Info
    private (set) var paymentViewData: PXNewCustomViewData?
    private (set) var paymentInfo: PXPaymentInfo?
    
    // Tracking
    private(set) var trackingPath: String = "" //TODO
    private(set) var trackingValues: [String : Any] = [:] //TODO
    // This field is ment to be used only by Checkout
    private(set) var flowBehaviourResult: PXResultKey?
    
    // Error
    private(set) var errorBodyView: UIView?
    
    private(set) var navigationController: UINavigationController?
    
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
    public func withStatus(_ status: PXBusinessResultStatus) -> PXPaymentCongrats {
        self.status = status
        return self
    }
    
    /**
     Any color for showing in the congrats' header. This should be used ONLY internally
     - parameter color: a color
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withHeaderColor(_ color: UIColor) -> PXPaymentCongrats {
        self.headerColor = color
        return self
    }
    
    /**
     Fills the header view with a message.
     - parameter title: some message
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withHeaderTitle(_ title: String) -> PXPaymentCongrats {
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
    public func withHeaderImage(_ image: UIImage?, orURL url: String?) -> PXPaymentCongrats {
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
    internal func withHeaderBadgeImage(_ image: UIImage) -> PXPaymentCongrats {
        self.headerBadgeImage = image
        return self
    }
    
    /**
     Top left close button configuration.
     - parameter action: a colsure to excecute
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withHeaderCloseAction(_ action: @escaping () -> ()) -> PXPaymentCongrats {
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
    public func withPointsData(percentage: Double, levelColor: String, levelNumber: Int, title: String, actionLabel: String, actionTarget: String) -> PXPaymentCongrats {
        let action = PXRemoteAction(label: actionLabel, target: actionTarget)
        self.points = PXPoints(progress: PXPointsProgress(percentage: percentage, levelColor: levelColor, levelNumber: levelNumber), title: title, action: action)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func withDiscountsData() -> PXPaymentCongrats {
        self.discounts = PXDiscounts(title: "Descuentos por tu nivel", subtitle: "", discountsAction: PXRemoteAction(label: "Ver todos los descuentos", target: "mercadopago://discount_center_payers/list#from=/px/congrats"), downloadAction: PXDownloadAction(title: "Exclusivo con la app de Mercado Libre", action: PXRemoteAction(label: "Descargar", target: "https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml")), items: [PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats", campaingId: "1018483"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/826105-MLA32568902631_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018457&user_level=1&mcc=4771701&distance=543968&coupon_used=false&status=FULL&store_id=30316240&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F826105-MLA32568902631_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2015%22%2C%22subtitle%22%3A%22Drogasil%22%7D%7D%5D#from=/px/congrats", campaingId: "1018457"),PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/761600-MLA32568902662_102019-O.jpg", title: "Hasta", subtitle: "10 % OFF", target:  "mercadopago://discount_center_payers/detail?campaign_id=1018475&user_level=1&mcc=5611201&distance=654418&coupon_used=false&status=FULL&store_id=30108872&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F761600-MLA32568902662_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22McDonald%5Cu0027s%22%7D%7D%5D#from=/px/congrats", campaingId:"1018475") ], touchpoint: nil)
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    #warning("Check if backgroundColor, textColor, weight should be customized from the outside")
    @discardableResult
    public func withExpenseSplit(_ message: String?, backgroundColor: String?, textColor: String?, weight: String?, actionLabel: String, actionTarget: String?, imageURL: String) -> PXPaymentCongrats {
        self.expenseSplit = PXExpenseSplit(title: PXText(message: message, backgroundColor: nil, textColor: nil, weight: weight), action: PXRemoteAction(label: actionLabel, target: actionTarget), imageUrl: imageURL)
        return self
    }

    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func withCrossSellingData() -> PXPaymentCongrats {
        self.crossSelling = [PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))]
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func withViewReceiptAction(label: String, target: String) -> PXPaymentCongrats {
        self.viewReceiptAction = PXRemoteAction(label: label, target: target)
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func withTopTextBox(message: String?, backgroundColor: String?, textColor: String?, weight: String?) -> PXPaymentCongrats {
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
    public func withInstructionView(_ view: UIView) -> PXPaymentCongrats {
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
    public func withMainAction(label: String, action: @escaping () -> ()) -> PXPaymentCongrats {
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
    public func withSecondaryAction(label: String, action: @escaping () -> ()) -> PXPaymentCongrats {
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
    public func withCustomViews(important: UIView?, top: UIView?, bottom: UIView?) -> PXPaymentCongrats {
        self.importantView = important
        self.topView = top
        self.bottomView = bottom
        return self
    }
    
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func paymentHasBeenRejectedWithRemedy(_ hasRemedies: Bool) -> PXPaymentCongrats {
        self.hasPaymentBeenRejectedWithRemedy = hasRemedies
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func withRemedyButtonAction(_ action: @escaping (String?) -> ()) -> PXPaymentCongrats {
        self.remedyButtonAction = action
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func withCreditsExpectationView(_ view: UIView) -> PXPaymentCongrats {
        self.creditsExpectationView = view
        return self
    }
    
    /**
    Data containing all of the information for displaying the payment method. This should be used ONLY internally
     - parameter viewData: a DTO for creating a `PXNewCustomView` representing the payment method
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withPaymentViewData(_ viewData: PXNewCustomViewData) -> PXPaymentCongrats {
        self.paymentViewData = viewData
        return self
    }
    
    /**
     Data containing all of the information for displaying the payment method .
     - parameter paymentInfo: a DTO for creating a `PXPaymentInfo` representing the payment method
     - returns: tihs builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withPaymentMethodInfo(_ paymentInfo: PXPaymentInfo) -> PXPaymentCongrats {
        self.paymentInfo = paymentInfo
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    internal func withFlowBehaviorResult(_ result: PXResultKey) -> PXPaymentCongrats {
        self.flowBehaviourResult = result
        return self
    }
    
    /**
     An error view to be displayed when a failure congrats is shown
     - parameter shouldShow: a `Bool` indicating if
     - returns: tihs builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withErrorBodyView(_ view: UIView) -> PXPaymentCongrats {
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
        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: self)
        viewModel.launch()
        return self
    }
}


//TODO: Move to another file
public class PXPaymentInfo: NSObject {
    let amount: String
    let paymentMethodName: String
    let paymentMethodLastFourDigits: String
    let paymentMethodExtraInfo: String?
    let paymentMethodId: String
    let paymentMethodType: PXPaymentTypes
    
    public init(amount: String, paymentMethodName: String, paymentMethodLastFourDigits: String, paymentMethodExtraInfo: String, paymentMethodId: String, paymentMethodType: PXPaymentTypes) {
        self.amount = amount
        self.paymentMethodName = paymentMethodName
        self.paymentMethodLastFourDigits = paymentMethodLastFourDigits
        self.paymentMethodExtraInfo = paymentMethodExtraInfo
        self.paymentMethodId = paymentMethodId
        self.paymentMethodType = paymentMethodType
        super.init()
    }
}
