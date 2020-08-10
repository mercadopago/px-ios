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
     - parameter action: a closure to excecute
     - returns: tihs builder `PXPaymentCongrats`
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
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func shouldShowReceipt(_ shouldShow: Bool, receiptId: String?) -> PXPaymentCongrats {
        self.shouldShowReceipt = shouldShow
        self.receiptId = receiptId
        return self
    }
    
    /**
      Defines the points data in the points seccions of the congrats.
     - parameter points: some PXPoints
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withPoints(_ points: PXPoints) -> PXPaymentCongrats {
        self.points = points
        return self
    }

    /**
     Defines the discounts data in the discounts seccions of the congrats.
     - parameter discounts: some PXDiscounts
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withDiscounts(_ discounts: PXDiscounts) -> PXPaymentCongrats {
        self.discounts = discounts
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
     Defines the cross selling data in the cross selling seccions of the congrats.
     - parameter crossSellingItems: an array of PXCrossSellingItem
     - returns: tihs builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withCrossSelling(_ items: [PXCrossSellingItem] ) -> PXPaymentCongrats {
        self.crossSelling = items
        return self
    }
    
    /**
     - ToDo: Fill this
    */
    @discardableResult
    public func withViewReceiptAction(action: PXRemoteAction) -> PXPaymentCongrats {
        self.viewReceiptAction = action
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
     - parameter action: a closure to excecute
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
     - parameter action: a closure to excecute
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
