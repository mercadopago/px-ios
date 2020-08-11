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
    
    private(set) var hasCustomOrder: Bool?
    /* --- Ponints & Discounts --- */
    
    // Instructions
    private(set) var instructionsView: UIView?
    
    // Footer Buttons
    private(set) var mainAction: PXAction?
    private(set) var secondaryAction: PXAction?
    
    // CustomViews
    private(set) var topView: UIView?
    private(set) var importantView: UIView?
    private(set) var bottomView: UIView?
    
    // Remedies
    private(set) var remedyButtonAction: ((String?) -> ())?
    private(set) var remedyView: UIView?
    
    private(set) var callback: ((PaymentResult.CongratsState, String?) -> Void)?
    
    private(set) var creditsExpectationView: UIView?
    
    // Payment Info
    private(set) var paymentInfo: PXCongratsPaymentInfo?
    
    // Split
    private(set) var splitPaymentInfo: PXCongratsPaymentInfo?
    
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
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withStatus(_ status: PXBusinessResultStatus) -> PXPaymentCongrats {
        self.status = status
        return self
    }
    
    /**
     Any color for showing in the congrats' header. This should be used ONLY internally
     - parameter color: a color
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withHeaderColor(_ color: UIColor) -> PXPaymentCongrats {
        self.headerColor = color
        return self
    }
    
    /**
     Fills the header view with a message.
     - parameter title: some message
     - returns: this builder `PXPaymentCongrats`
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
     - returns: this builder `PXPaymentCongrats`
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
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withHeaderBadgeImage(_ image: UIImage) -> PXPaymentCongrats {
        self.headerBadgeImage = image
        return self
    }
    
    /**
     Top left close button configuration.
     - parameter action: a closure to excecute
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withHeaderCloseAction(_ action: @escaping () -> ()) -> PXPaymentCongrats {
        self.headerCloseAction = action
        return self
    }
    
    /**
     Defines if the receipt view should be shown, in affirmative case, the receiptId must be supplied.
     - parameter shouldShow: the boolean value that defines if the view will be show or not.
     - parameter receiptId: ID of the receipt
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func shouldShowReceipt(receiptId: String?) -> PXPaymentCongrats {
        self.receiptId = receiptId
        return self
    }
    
    /**
      Defines the points data in the points seccions of the congrats.
     - parameter points: some PXPoints
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withPoints(_ points: PXPoints?) -> PXPaymentCongrats {
        self.points = points
        return self
    }
    
    /**
     Defines the discounts data in the discounts seccions of the congrats.
     - parameter discounts: some PXDiscounts
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withDiscounts(_ discounts: PXDiscounts?) -> PXPaymentCongrats {
        self.discounts = discounts
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    #warning("Check if backgroundColor, textColor, weight should be customized from the outside")
    @discardableResult
    public func withExpenseSplit(_ text: PXText, action: PXRemoteAction, imageURL: String) -> PXPaymentCongrats {
        self.expenseSplit = PXExpenseSplit(title: text, action: action, imageUrl: imageURL)
        return self
    }
    
    /**
     Defines the cross selling data in the cross selling seccions of the congrats.
     - parameter crossSellingItems: an array of PXCrossSellingItem
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withCrossSelling(_ items: [PXCrossSellingItem]? ) -> PXPaymentCongrats {
        self.crossSelling = items
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func withViewReceiptAction(action: PXRemoteAction?) -> PXPaymentCongrats {
        self.viewReceiptAction = action
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func shouldHaveCustomOrder(_ customOrder: Bool?) -> PXPaymentCongrats {
        self.hasCustomOrder = customOrder
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func withInstructionView(_ view: UIView?) -> PXPaymentCongrats {
        self.instructionsView = view
        return self
    }
    
    /**
     Top button configuration.
     - parameter label: button display text
     - parameter action: a closure to excecute
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withMainAction(_ action: PXAction?) -> PXPaymentCongrats {
        self.mainAction = action
        return self
    }
    
    /**
     Bottom button configuration.
     - parameter label: button display text
     - parameter action: a closure to excecute
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withSecondaryAction(_ action: PXAction?) -> PXPaymentCongrats {
        self.secondaryAction = action
        return self
    }
    
    /**
     Custom views to be displayed.
     - Parameters:
        - important: some `UIView`
        - top: some `UIView`
        - bottom: some `UIView`
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withCustomViews(important: UIView?, top: UIView?, bottom: UIView?) -> PXPaymentCongrats {
        self.importantView = important
        self.topView = top
        self.bottomView = bottom
        return self
    }
    
    /**
     If the congrats has remedy, recieves a custom view to be displayed.
     - Parameters:
        - remedyView: some `UIView`
        - remedyButtonAction: some `closure`
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withRemedyView(remedyView: UIView?, _ remedyButtonAction: ((String?) -> ())?) -> PXPaymentCongrats {
        self.remedyView = remedyView
        self.remedyButtonAction = remedyButtonAction
        return self
    }
    
    /**
    A callback that can be executed in any other method, this callback is used in the remedies flow
    and also is triggered when headerCloseAction or the extra buttons in the footer view are triggered, is part of the checkout process.
    - Parameters:
       - callback: some closure
    - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withCallback(_ callback: @escaping ((PaymentResult.CongratsState, String?) -> Void)) -> PXPaymentCongrats {
        self.callback = callback
        return self
    }
    
    /**
     - ToDo: Fill this
     */
    @discardableResult
    public func withCreditsExpectationView(_ view: UIView?) -> PXPaymentCongrats {
        self.creditsExpectationView = view
        return self
    }
    
    /**
     Data containing all of the information for displaying the payment method .
     - parameter paymentInfo: a DTO for creating a `PXCongratsPaymentInfo` representing the payment method
     - returns: tihs builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withPaymentMethodInfo(_ paymentInfo: PXCongratsPaymentInfo) -> PXPaymentCongrats {
        self.paymentInfo = paymentInfo
        return self
    }
    
    /**
     Data containing all of the information for displaying the split payment method .
     - parameter paymentInfo: a DTO for creating a `PXCongratsPaymentInfo` representing the payment method
     - returns: tihs builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withSplitPaymenInfo(_ splitPaymentInfo: PXCongratsPaymentInfo) -> PXPaymentCongrats {
        self.splitPaymentInfo = splitPaymentInfo
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
     - parameter shouldShow: a `Bool` indicating if the error screen should be shown.
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withErrorBodyView(_ view: UIView?) -> PXPaymentCongrats {
        self.errorBodyView = view
        return self
    }
    
    /**
     Shows the congrats' view.
     - parameter navController: a `UINavigationController`
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func start(using navController: UINavigationController) -> PXPaymentCongrats {
        self.navigationController = navController
        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: self)
        viewModel.launch()
        return self
    }
}
