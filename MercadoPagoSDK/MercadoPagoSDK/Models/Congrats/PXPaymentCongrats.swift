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
    private(set) var type: PXCongratsType = .REJECTED
    private(set) var headerColor: UIColor?
    private(set) var headerTitle: String = ""
    private(set) var headerURL: String?
    private(set) var headerCloseAction: (() -> ())?
    private(set) var headerImage: UIImage?
    private(set) var headerBadgeImage: UIImage?
    
    // Receipt
    private(set) var shouldShowReceipt: Bool = false
    private(set) var receiptId: String?
    private(set) var receiptAction: PXRemoteAction?
    
    // Points
    private(set) var points: PXPoints?
    
    // Discounts
    private(set) var discounts: PXDiscounts?
    
    // Expense split
    private(set) var expenseSplit: PXExpenseSplit?
    
    // CrossSelling
    private(set) var crossSelling: [PXCrossSellingItem]?
    
    // Place receipt view and payment view over points and crosselling? Default is false
    private(set) var hasCustomSorting: Bool = false
    
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
    private(set) var remedyViewData: PXRemedyViewData?
    
    private(set) var creditsExpectationView: UIView?
    
    // Payment Info
    private(set) var shouldShowPaymentMethod: Bool = false
    private(set) var paymentInfo: PXCongratsPaymentInfo?
    private(set) var statementDescription : String?
    
    // Split
    private(set) var splitPaymentInfo: PXCongratsPaymentInfo?
    
    // Tracking
    private(set) var trackingValues: [String : Any] = [:]
    
    private(set) var flowBehaviourResult: PXResultKey?
    
    // Error
    private(set) var errorBodyView: UIView?
    
    private(set) var navigationController: UINavigationController?
    
    // URLs
    private(set) var shouldAutoReturn: Bool = false
    private(set) var redirectURL: URL?

    // MARK: Initializer
    
    public override init() {
        super.init()
    }
}

// MARK: Internal API
extension PXPaymentCongrats {
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
     Collector image shown in congrats' header. Can receive an `UIImage` or a `URL`.
     - parameter image: an image in `UIImage` format
     - parameter url: an `URL` for the image
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withHeaderImage(_ image: UIImage?) -> PXPaymentCongrats {
        self.headerImage = image
        return self
    }
    
    /**
     Collector badge image shown in congrats' header. This should be used ONLY internally
     - parameter image: an image in `UIImage` format
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withHeaderBadgeImage(_ image: UIImage?) -> PXPaymentCongrats {
        self.headerBadgeImage = image
        return self
    }
    
    /**
     Defines how will be the sort of the component in the Congrats
     - parameter customSorting: a boolean
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withCustomSorting(_ customSorting: Bool?) -> PXPaymentCongrats {
        self.hasCustomSorting = customSorting ?? false
        return self
    }

    /**
     This is used in paymentResult on checkout Process, define
     - parameter view: some UIView
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withInstructionView(_ view: UIView?) -> PXPaymentCongrats {
        self.instructionsView = view
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
    internal func withRemedyViewData(_ remedyViewData: PXRemedyViewData?) -> PXPaymentCongrats {
        self.remedyViewData = remedyViewData
        return self
    }
    
    /**
    This is used to track how the flow finished,
    - parameter result: some PXResultKey
    - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    internal func withFlowBehaviorResult(_ result: PXResultKey) -> PXPaymentCongrats {
        self.flowBehaviourResult = result
        return self
    }
    
    /**
    The data that will be requested for internal tracking
    - parameter trackingProperties: a `[String:Any]`
    - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withTrackingProperties(_ trackingProperties: [String: Any]) -> PXPaymentCongrats {
        self.trackingValues = trackingProperties
        return self
    }
    
    /**
    Navigate to another place when closing Congrats
    - parameter redirectURL: a `URL`
    - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withRedirectURLs(_ redirectURL: URL?) -> PXPaymentCongrats {
        self.redirectURL = redirectURL
        return self
    }

    /**
    Close the congrats automatically after a period of time
    - parameter shouldAutoReturn: a `Bool`
    - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func shouldAutoReturn(_ shouldAutoReturn: Bool) -> PXPaymentCongrats {
        self.shouldAutoReturn = shouldAutoReturn
        return self
    }
}

// MARK: Public API
extension PXPaymentCongrats {
    /**
     Indicates status Success, Failure, for more info check `PXCongratsType`.
     - parameter type: the result status
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withCongratsType(_ type: PXCongratsType) -> PXPaymentCongrats {
        self.type = type
        return self
    }
    
    /**
     Fills the header view with a message.
     - parameter title: some message
     - parameter imageURL: an `URL` for the image
     - parameter action: a closure to excecute when the top exit button is pressed.
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withHeader(title: String, imageURL: String?, closeAction: @escaping () -> ()) -> PXPaymentCongrats {
        self.headerTitle = title
        self.headerURL = imageURL
        self.headerCloseAction = closeAction
        return self
    }
    
    /**
     Defines if the receipt view should be shown, in affirmative case, the receiptId must be supplied.
     - parameter shouldShowReceipt: a boolean indicating if the receipt view is displayed.
     - parameter receiptId: ID of the receipt
     - parameter action: action when the receipt view is pressed.
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withReceipt(shouldShowReceipt: Bool, receiptId: String?, action: PXRemoteAction?) -> PXPaymentCongrats {
        self.shouldShowReceipt = shouldShowReceipt
        self.receiptId = receiptId
        self.receiptAction = action
        return self
    }
    
    /**
      Defines the points data in the points seccions of the congrats.
     - parameter points: some PXPoints
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withLoyalty(_ points: PXPoints?) -> PXPaymentCongrats {
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
     Defines the Expense Split data in the expense split seccions of the congrats.
     - parameter expenseSplit: some PXExpenseSplit
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withExpenseSplit(_ expenseSplit: PXExpenseSplit? ) -> PXPaymentCongrats {
        self.expenseSplit = expenseSplit
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
     Top button configuration.
     - parameter label: button display text
     - parameter action: a closure to excecute
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withFooterMainAction(_ action: PXAction?) -> PXPaymentCongrats {
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
    public func withFooterSecondaryAction(_ action: PXAction?) -> PXPaymentCongrats {
        self.secondaryAction = action
        return self
    }

    /**
     Top Custom view to be displayed.
     - parameter view: some `UIView`
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withTopView(_ view: UIView?)  -> PXPaymentCongrats {
        self.topView = view
        return self
    }
    /**
     Important Custom view to be displayed.
     - parameter view: some `UIView`
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withImportantView(_ view: UIView?)  -> PXPaymentCongrats {
        self.importantView = view
        return self
    }

    /**
     Bottom Custom view to be displayed.
     - parameter view: some `UIView`
     - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    public func withBottomView(_ view: UIView?)  -> PXPaymentCongrats {
        self.bottomView = view
        return self
    }
    
    /**
     This view is shown if there has been a payment with credit.
     - parameter view: some `UIView`
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withCreditsExpectationView(_ view: UIView?) -> PXPaymentCongrats {
        self.creditsExpectationView = view
        return self
    }
    /**
     Defines if the payment method (or split payment method) should be shown.
     - parameter shouldShowPaymentMethod: a `boolean` indication if it should be shown.
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func shouldShowPaymentMethod(_ shouldShowPaymentMethod: Bool) -> PXPaymentCongrats {
        self.shouldShowPaymentMethod = shouldShowPaymentMethod
        return self
    }
    
    /**
     Data containing all of the information for displaying the payment method .
     - parameter paymentInfo: a DTO for creating a `PXCongratsPaymentInfo` representing the payment method
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withPaymentMethodInfo(_ paymentInfo: PXCongratsPaymentInfo) -> PXPaymentCongrats {
        self.paymentInfo = paymentInfo
        return self
    }
    
    /**
     Data containing all of the information for displaying the split payment method .
     - parameter paymentInfo: a DTO for creating a `PXCongratsPaymentInfo` representing the payment method
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withSplitPaymentInfo(_ splitPaymentInfo: PXCongratsPaymentInfo) -> PXPaymentCongrats {
        self.splitPaymentInfo = splitPaymentInfo
        return self
    }
    
    /**
    If the paymentMehotd will be shown, and it is a credit card, this statemetnDescrption will be shown on the payment method view.
    - parameter statementDescription: some String
    - returns: this builder `PXPaymentCongrats`
    */
    @discardableResult
    internal func withStatementDescription(_ statementDescription: String?) -> PXPaymentCongrats {
        self.statementDescription = statementDescription
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
     The data and the configuration that will be requested for tracking
     - parameter trackingProperties: a `PXPaymentCongratsTracking`
     - parameter trackingConfiguration: a `PXTrackingConfiguration` with the following properties:
            flowName: The name of the flow using the congrats.
            flowDetail:  Extradata that the user of the congrats wants to track
            trackListener: a Class that conform the protocol TrackListener.
            sessionId: Optional if the user want to use the sessionId.
     - returns: this builder `PXPaymentCongrats`
     */
    @discardableResult
    public func withTracking(trackingProperties: PXPaymentCongratsTracking) -> PXPaymentCongrats {
        let trackingConfiguration = PXTrackingConfiguration(trackListener: trackingProperties.trackListener, flowName: trackingProperties.flowName, flowDetails: trackingProperties.flowDetails, sessionId: trackingProperties.sessionId)
        var properties: [String: Any] = [:]
        properties["style"] = "custom"
        properties["payment_method_id"] = paymentInfo?.paymentMethodId
        properties["payment_method_type"] = paymentInfo?.paymentMethodType.rawValue
        properties["payment_id"] = trackingProperties.paymentId
        properties["payment_status"] = type.getRawValue()
        properties["preference_amount"] = trackingProperties.totalAmount
        properties["payment_status_detail"] = trackingProperties.paymentStatusDetail
        
        if let campaingId = trackingProperties.campaingId {
            properties[PXCongratsTracking.TrackingKeys.campaignId.rawValue] = campaingId
        }
        
        if let currency = trackingProperties.currencyId {
            properties["currency_id"] = currency
        }
        
        properties["has_split_payment"] = splitPaymentInfo != nil
        properties[PXCongratsTracking.TrackingKeys.hasBottomView.rawValue] = bottomView != nil
        properties[PXCongratsTracking.TrackingKeys.hasTopView.rawValue] = topView != nil
        properties[PXCongratsTracking.TrackingKeys.hasImportantView.rawValue] = importantView != nil
        properties[PXCongratsTracking.TrackingKeys.hasExpenseSplitView.rawValue] = expenseSplit != nil
        properties[PXCongratsTracking.TrackingKeys.scoreLevel.rawValue] = points?.progress.levelNumber
        properties[PXCongratsTracking.TrackingKeys.discountsCount.rawValue] = discounts?.items.count
        
        trackingConfiguration.updateTracker()
        
        self.trackingValues = properties
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
