//
//  PXToDeprecate.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 31/7/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
// MARK: To deprecate v4 final.
@objcMembers open class PaymentResultScreenPreference: NSObject {

    static let PENDING_CONTENT_TITLE = "¿Qué puedo hacer?"
    static let REJECTED_CONTENT_TITLE = "¿Qué puedo hacer?"

    public enum ApprovedBadge {
        case pending
        case check
    }

    var topCustomComponent: PXCustomComponentizable?
    var bottomCustomComponent: PXCustomComponentizable?

    open func setApprovedTopCustomComponent(_ component: PXCustomComponentizable) {
        self.topCustomComponent = component
    }
    open func setApprovedBottomCustomComponent(_ component: PXCustomComponentizable) {
        self.bottomCustomComponent = component
    }
    open func getApprovedTopCustomComponent() -> PXCustomComponentizable? {
        return self.topCustomComponent
    }
    open func getApprovedBottomCustomComponent() -> PXCustomComponentizable? {
        return self.bottomCustomComponent
    }

    // MARK: FOOTER
    var approvedSecondaryExitButtonText = ""
    var approvedSecondaryExitButtonCallback: ((PaymentResult) -> Void)?

    var hidePendingSecondaryButton = false
    var pendingSecondaryExitButtonText: String?
    var pendingSecondaryExitButtonCallback: ((PaymentResult) -> Void)?

    var hideRejectedSecondaryButton = false
    var rejectedSecondaryExitButtonText: String?
    var rejectedSecondaryExitButtonCallback: ((PaymentResult) -> Void)?

    var exitButtonTitle: String?

    //HEADER
    // MARK: Approved
    var approvedBadge: ApprovedBadge? = ApprovedBadge.check
    var approvedTitle = PXHeaderResutlConstants.APPROVED_HEADER_TITLE.localized
    var approvedSubtitle = ""
    private var _approvedLabelText = ""
    private var _disableApprovedLabelText = true
    var approvedURLImage: String?
    var approvedIconName = "default_item_icon"
    var approvedIconBundle = MercadoPago.getBundle()!

    // MARK: Pending
    var pendingTitle = PXHeaderResutlConstants.PENDING_HEADER_TITLE.localized
    var pendingSubtitle = ""
    var pendingContentTitle = PaymentResultScreenPreference.PENDING_CONTENT_TITLE.localized
    var pendingContentText = ""
    private var _pendingLabelText = ""
    private var _disablePendingLabelText = true
    var pendingIconName = "default_item_icon"
    var pendingIconBundle = MercadoPago.getBundle()!
    var pendingURLImage: String?
    var hidePendingContentText = false
    var hidePendingContentTitle = false

    // MARK: Rejected
    var rejectedTitle = PXHeaderResutlConstants.REJECTED_HEADER_TITLE.localized
    var rejectedSubtitle = ""
    var rejectedTitleSetted = false
    private var disableRejectedLabelText = false
    var rejectedIconSubtext = PXHeaderResutlConstants.REJECTED_ICON_SUBTEXT.localized
    var rejectedBolbradescoIconName = "MPSDK_payment_result_bolbradesco_error"
    var rejectedPaymentMethodPluginIconName = "MPSDK_payment_result_plugin_error"
    var rejectedIconBundle = MercadoPago.getBundle()!
    var rejectedDefaultIconName: String?
    var rejectedURLImage: String?
    var rejectedIconName: String?
    var rejectedContentTitle = PaymentResultScreenPreference.REJECTED_CONTENT_TITLE.localized
    var rejectedContentText = ""
    var hideRejectedContentText = false
    var hideRejectedContentTitle = false

    // MARK: Commons
    var showBadgeImage = true
    var showLabelText = true
    open func shouldShowBadgeImage() {
        self.showBadgeImage = true
    }
    open func hideBadgeImage() {
        self.showBadgeImage = false
    }
    open func shouldShowLabelText() {
        self.showLabelText = true
    }
    open func hideLabelText() {
        self.showLabelText = false
    }

    //--
    var pmDefaultIconName = "card_icon"
    var pmBolbradescoIconName = "boleto_icon"
    var pmIconBundle = MercadoPago.getBundle()!
    var statusBackgroundColor: UIColor?
    var hideApprovedPaymentBodyCell = false
    var hideContentCell = false
    var hideAmount = false
    var hidePaymentId = false
    var hidePaymentMethod = false

    // MARK: Sets de Approved
    open func getApprovedBadgeImage() -> UIImage? {
        guard let badge = approvedBadge else {
            return nil
        }
        if badge == ApprovedBadge.check {
            return MercadoPago.getImage("ok_badge")
        } else if badge == ApprovedBadge.pending {
            return MercadoPago.getImage("pending_badge")
        }
        return nil
    }
    open func disableApprovedLabelText() {
        self._disableApprovedLabelText = true
    }

    open func setApproved(labelText: String) {
        self._disableApprovedLabelText = false
        self._approvedLabelText = labelText
    }
    open func getApprovedLabelText() -> String? {
        if self._disableApprovedLabelText {
            return nil
        } else {
            return self._approvedLabelText
        }
    }
    open func setBadgeApproved(badge: ApprovedBadge) {
        self.approvedBadge = badge
    }

    open func setApproved(title: String) {
        self.approvedTitle = title
    }

    @available(*, deprecated)
    open func setApprovedSubtitle(subtitle: String) {
        self.approvedSubtitle = subtitle
    }

    open func setApprovedHeaderIcon(name: String, bundle: Bundle) {
        self.approvedIconName = name
        self.approvedIconBundle = bundle
    }

    open func setApprovedHeaderIcon(stringURL: String) {
        self.approvedURLImage = stringURL
    }

    // MARK: Sets de Pending

    open func disablePendingLabelText() {
        self._disablePendingLabelText = true
    }

    open func setPending(labelText: String) {
        self._disablePendingLabelText = false
        self._pendingLabelText = labelText
    }
    open func getPendingLabelText() -> String? {
        if self._disablePendingLabelText {
            return nil
        } else {
            return self._pendingLabelText
        }
    }
    open func setPending(title: String) {
        self.pendingTitle = title
    }

    @available(*, deprecated)
    open func setPendingSubtitle(subtitle: String) {
        self.pendingSubtitle = subtitle
    }

    open func setPendingHeaderIcon(name: String, bundle: Bundle) {
        self.pendingIconName = name
        self.pendingIconBundle = bundle
    }

    open func setPendingHeaderIcon(stringURL: String) {
        self.pendingURLImage = stringURL
    }

    open func setPendingContentText(text: String) {
        self.pendingContentText = text
    }

    open func setPendingContentTitle(title: String) {
        self.pendingContentTitle = title
    }

    open func disablePendingSecondaryExitButton() {
        self.hidePendingSecondaryButton = true
    }

    open func disablePendingContentText() {
        self.hidePendingContentText = true
    }

    open func disablePendingContentTitle() {
        self.hidePendingContentTitle = true
    }

    // MARK: Sets de rejected

    open func setRejected(title: String) {
        self.rejectedTitle = title
        self.rejectedTitleSetted = true
    }

    @available(*, deprecated)
    open func setRejectedSubtitle(subtitle: String) {
        self.rejectedSubtitle = subtitle
    }

    open func setRejectedHeaderIcon(name: String, bundle: Bundle) {
        self.rejectedIconName = name
        self.rejectedIconBundle = bundle
    }

    open func setRejectedHeaderIcon(stringURL: String) {
        self.rejectedURLImage = stringURL
    }

    open func setRejectedContentText(text: String) {
        self.rejectedContentText = text
    }

    open func setRejectedContentTitle(title: String) {
        self.rejectedContentTitle = title
    }

    open func disableRejectedLabel() {
        self.disableRejectedLabelText = true
    }

    @available(*, deprecated)
    open func setRejectedIconSubtext(text: String) {
        self.rejectedIconSubtext = text
        if text.count == 0 {
            self.disableRejectedLabelText = true
        }
    }

    open func disableRejectdSecondaryExitButton() {
        self.hideRejectedSecondaryButton = true
    }

    open func disableRejectedContentText() {
        self.hideRejectedContentText = true
    }

    open func disableRejectedContentTitle() {
        self.hideRejectedContentTitle = true
    }

    open func setExitButtonTitle(title: String) {
        self.exitButtonTitle = title
    }

    // MARK: Sets cross status

    open func setStatusBackgroundColor(color: UIColor) {
        self.statusBackgroundColor = color
    }

    open func getStatusBackgroundColor() -> UIColor? {
        return statusBackgroundColor
    }

    // MARK: Disables

    open func disableContentCell() {
        self.hideContentCell = true
    }

    open func disableApprovedBodyCell() {
        self.hideApprovedPaymentBodyCell = true
    }

    open func disableApprovedAmount() {
        self.hideAmount = true
    }

    open func disableApprovedReceipt() {
        self.hidePaymentId = true
    }

    open func disableApprovedPaymentMethodInfo() {
        self.hidePaymentMethod = true
    }

    open func enableAmount() {
        self.hideAmount = false
    }

    open func enableApprovedReceipt() {
        self.hidePaymentId = true
    }

    open func enableContnentCell() {
        self.hideContentCell = false
    }

    open func enableApprovedPaymentBodyCell() {
        self.hideApprovedPaymentBodyCell = false
    }

    open func enablePaymentContentText() {
        self.hidePendingContentText = false
    }

    open func enablePaymentContentTitle() {
        self.hidePendingContentTitle = false
    }

    open func enableApprovedPaymentMethodInfo() {
        self.hidePaymentMethod = false
    }

    // MARK: Approved

    open func getApprovedTitle() -> String {
        return approvedTitle
    }

    open func getApprovedSubtitle() -> String {
        return approvedSubtitle
    }

    open func getApprovedSecondaryButtonText() -> String {
        return approvedSecondaryExitButtonText
    }

    open func getHeaderApprovedIcon() -> UIImage? {
        if let urlImage = approvedURLImage {
            if let image =  ViewUtils.loadImageFromUrl(urlImage) {
                return image
            }
        }
        return MercadoPago.getImage(approvedIconName, bundle: approvedIconBundle)
    }

    // MARK: Pending

    open func getPendingTitle() -> String {
        return pendingTitle
    }

    open func getPendingSubtitle() -> String {
        return pendingSubtitle
    }

    open func getHeaderPendingIcon() -> UIImage? {
        if let urlImage = self.pendingURLImage {
            if let image =  ViewUtils.loadImageFromUrl(urlImage) {
                return image
            }
        }
        return MercadoPago.getImage(pendingIconName, bundle: pendingIconBundle)
    }

    open func getPendingContetTitle() -> String {
        return pendingContentTitle
    }

    open func getPendingContentText() -> String {
        return pendingContentText
    }

    open func getPendingSecondaryButtonText() -> String? {
        return pendingSecondaryExitButtonText
    }


    open func isPendingSecondaryExitButtonDisable() -> Bool {
        return hidePendingSecondaryButton
    }

    open func isPendingContentTextDisable() -> Bool {
        return hidePendingContentText
    }

    open func isPendingContentTitleDisable() -> Bool {
        return hidePendingContentTitle
    }

    // MARK: Rejected

    open func getRejectedTitle() -> String {
        return rejectedTitle
    }

    open func getRejectedSubtitle() -> String {
        return rejectedSubtitle
    }

    open func setHeaderRejectedIcon(name: String, bundle: Bundle) {
        self.rejectedDefaultIconName = name
        self.approvedIconBundle = bundle
    }

    open func getHeaderRejectedIcon(_ paymentMethod: PaymentMethod?) -> UIImage? {
        if let urlImage = self.rejectedURLImage {
            if let image =  ViewUtils.loadImageFromUrl(urlImage) {
                return image
            }
        }
        if rejectedIconName != nil {
            return MercadoPago.getImage(rejectedIconName, bundle: rejectedIconBundle)
        }
        return getHeaderImageFor(paymentMethod)
    }

    open func getHeaderImageFor(_ paymentMethod: PaymentMethod?) -> UIImage? {
        guard let paymentMethod = paymentMethod else {
            return MercadoPago.getImage(pmDefaultIconName, bundle: pmIconBundle)
        }

        if paymentMethod.isBolbradesco {
            return MercadoPago.getImage(pmBolbradescoIconName, bundle: pmIconBundle)
        }

        if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            return MercadoPago.getImage(rejectedPaymentMethodPluginIconName, bundle: rejectedIconBundle)
        }
        return MercadoPago.getImage(pmDefaultIconName, bundle: pmIconBundle)
    }

    open func getRejectedContetTitle() -> String {
        return rejectedContentTitle
    }

    open func getRejectedContentText() -> String {
        return rejectedContentText
    }

    open func getRejectedIconSubtext() -> String {
        return rejectedIconSubtext
    }

    open func getRejectedSecondaryButtonText() -> String? {
        return rejectedSecondaryExitButtonText
    }

    open func isRejectedSecondaryExitButtonDisable() -> Bool {
        return hideRejectedSecondaryButton
    }

    open func isRejectedContentTextDisable() -> Bool {
        return hideRejectedContentText
    }

    open func isRejectedContentTitleDisable() -> Bool {
        return hideRejectedContentTitle
    }

    open func getExitButtonTitle() -> String? {
        if let title = exitButtonTitle {
            return title.localized
        }
        return nil
    }

    open func isContentCellDisable() -> Bool {
        return hideContentCell
    }

    open func isApprovedPaymentBodyDisableCell() -> Bool {
        return hideApprovedPaymentBodyCell
    }

    open func isPaymentMethodDisable() -> Bool {
        return hidePaymentMethod
    }

    open func isAmountDisable() -> Bool {
        return hideAmount
    }

    open func isPaymentIdDisable() -> Bool {
        return hidePaymentId
    }
}

// MARK: To deprecate v4 final.
/** :nodoc: */
@objcMembers open class ReviewScreenPreference: NSObject {

    fileprivate static let DEFAULT_AMOUNT_TITLE = "Precio Unitario: ".localized
    fileprivate static let DEFAULT_QUANTITY_TITLE = "Cantidad: ".localized

    let summaryTitles: [SummaryType: String] = [SummaryType.PRODUCT: "Producto".localized, SummaryType.ARREARS: "Mora".localized, SummaryType.CHARGE: "Cargos".localized,
                                                SummaryType.DISCOUNT: "Descuentos".localized, SummaryType.TAXES: "Impuestos".localized, SummaryType.SHIPPING: "Envío".localized]

    var details: [SummaryType: SummaryDetail] = [SummaryType: SummaryDetail]()

    fileprivate var itemsEnable: Bool = true
    fileprivate var shouldDisplayChangeMethodOption = true
    fileprivate var quantityRowVisible: Bool = true
    fileprivate var displayAmountTitle: Bool = true

    fileprivate var amountTitle = DEFAULT_AMOUNT_TITLE
    fileprivate var quantityTitle = DEFAULT_QUANTITY_TITLE
    fileprivate var collectorIcon: UIImage?
    fileprivate var disclaimerText: String?
    fileprivate var disclaimerTextColor: UIColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()
    fileprivate var topCustomComponent: PXCustomComponentizable?
    fileprivate var bottomCustomComponent: PXCustomComponentizable?

    fileprivate var itemsReview: ItemsReview = ItemsReview() //Revisar
}

/** :nodoc: */
// Not in Android.
// MARK: Payment method.
extension ReviewScreenPreference {
    open func isChangeMethodOptionEnabled() -> Bool {
        return shouldDisplayChangeMethodOption
    }

    open func disableChangeMethodOption() {
        self.shouldDisplayChangeMethodOption = false
    }

    open func enableChangeMethodOption() {
        self.shouldDisplayChangeMethodOption = true
    }
}

/** :nodoc: */
// MARK: Items.
extension ReviewScreenPreference {
    // hasItemsEnable (In Android)
    open func isItemsEnable() -> Bool {
        return itemsEnable
    }

    open func disableItems() {
        self.itemsEnable = false
    }
    // Not in Android.
    open func enableItems() {
        self.itemsEnable = true
    }
}

/** :nodoc: */
// Not in Android.
// MARK: Amount title.
extension ReviewScreenPreference {
    open func hideAmountTitle() {
        displayAmountTitle = false
    }

    open func showAmountTitle() {
        displayAmountTitle = true
    }

    open func shouldShowAmountTitle() -> Bool {
        return displayAmountTitle
    }

    open func setAmountTitle(title: String ) {
        self.amountTitle = title
    }

    open func getAmountTitle() -> String {
        return amountTitle
    }
}

/** :nodoc: */
// MARK: Collector icon.
extension ReviewScreenPreference {
    open func setCollectorIcon(image: UIImage) {
        collectorIcon = image
    }

    open func getCollectorIcon() -> UIImage? {
        return collectorIcon
    }
}

/** :nodoc: */
// MARK: Quantity row.
extension ReviewScreenPreference {
    // Not in Android.
    open func shouldShowQuantityRow() -> Bool {
        return quantityRowVisible
    }
    // Not in Android.
    open func hideQuantityRow() {
        self.quantityRowVisible = false
    }
    // Not in Android.
    open func showQuantityRow() {
        self.quantityRowVisible = true
    }

    open func setQuantityLabel(title: String ) {
        if title.isEmpty {
            self.hideQuantityRow()
        }
        self.quantityTitle = title
    }

    open func getQuantityLabel() -> String {
        return quantityTitle
    }
}

/** :nodoc: */
// MARK: Disclaimer text.
extension ReviewScreenPreference {
    open func getDisclaimerText() -> String? {
        return disclaimerText
    }

    open func setDisclaimerText(text: String) {
        disclaimerText = text
    }

    open func getDisclaimerTextColor() -> UIColor {
        return disclaimerTextColor
    }

    open func setDisclaimerTextColor(color: UIColor) {
        disclaimerTextColor = color
    }
}

/** :nodoc: */
// MARK: - Custom components.
extension ReviewScreenPreference {
    open func setTopComponent(_ component: PXCustomComponentizable) {
        self.topCustomComponent = component
    }

    open func setBottomComponent(_ component: PXCustomComponentizable) {
        self.bottomCustomComponent = component
    }

    open func getTopComponent() -> PXCustomComponentizable? {
        return self.topCustomComponent
    }

    open func getBottomComponent() -> PXCustomComponentizable? {
        return self.bottomCustomComponent
    }
}

/** :nodoc: */
// MARK: - Summary.
extension ReviewScreenPreference {
    // Not in Android.
    public func clearSummaryDetails() {
        self.details = [SummaryType: SummaryDetail]()
    }
    // Not in Android.
    public func addSummaryProductDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.PRODUCT)
    }

    public func addSummaryDiscountDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.DISCOUNT)
    }

    public func addSummaryTaxesDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.TAXES)
    }

    public func addSummaryShippingDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.SHIPPING)
    }

    public func addSummaryArrearsDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.ARREARS)
    }

    public func setSummaryProductTitle(productTitle: String) {
        self.updateTitle(type: SummaryType.PRODUCT, title: productTitle)
    }

    fileprivate func updateTitle(type: SummaryType, title: String) {
        if self.details[type] != nil {
            self.details[type]?.title = title
        } else {
            self.details[type] = SummaryDetail(title: title, detail: nil)
        }
        if type == SummaryType.DISCOUNT {
            self.details[type]?.titleColor = UIColor.mpGreenishTeal()
            self.details[type]?.amountColor = UIColor.mpGreenishTeal()
        }
    }

    fileprivate func getOneWordDescription(oneWordDescription: String) -> String {
        if oneWordDescription.count <= 0 {
            return ""
        }
        if let firstWord = oneWordDescription.components(separatedBy: " ").first {
            return firstWord
        } else {
            return oneWordDescription
        }
    }

    fileprivate func addDetail(detail: SummaryItemDetail, type: SummaryType) {
        if self.details[type] != nil {
            self.details[type]?.details.append(detail)
        } else {
            guard let title = self.summaryTitles[type] else {
                self.details[type] = SummaryDetail(title: "", detail: detail)
                return
            }
            self.details[type] = SummaryDetail(title: title, detail: detail)
        }
        if type == SummaryType.DISCOUNT {
            self.details[type]?.titleColor = UIColor.mpGreenishTeal()
            self.details[type]?.amountColor = UIColor.mpGreenishTeal()
        }
    }

    func getSummaryTotalAmount() -> Double {
        var totalAmount = 0.0
        guard let productDetail = details[SummaryType.PRODUCT] else {
            return 0.0
        }
        if productDetail.getTotalAmount() <= 0 {
            return 0.0
        }
        for summaryType in details.keys {
            if let detailAmount = details[summaryType]?.getTotalAmount() {
                if summaryType == SummaryType.DISCOUNT {
                    totalAmount -= detailAmount
                } else {
                    totalAmount += detailAmount
                }
            }
        }
        return totalAmount
    }
}

/** :nodoc: */
extension MercadoPagoCheckout {
    internal class func showPayerCostDescription() -> Bool {
        let path = MercadoPago.getBundle()!.path(forResource: "PayerCostPreferences", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()

        if let siteDic = dictionary?.value(forKey: site) as? NSDictionary {
            if let payerCostDescription = siteDic.value(forKey: "payerCostDescription") as? Bool {
                return payerCostDescription
            }
        }

        return true
    }

    internal class func showBankInterestWarning() -> Bool {
        let path = MercadoPago.getBundle()!.path(forResource: "PayerCostPreferences", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()

        if let siteDic = dictionary?.value(forKey: site) as? NSDictionary {
            if let bankInsterestCell = siteDic.value(forKey: "bankInsterestCell") as? Bool {
                return bankInsterestCell
            }
        }

        return false
    }
}
