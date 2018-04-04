//
//  PaymentResultScreenPreference.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class PaymentResultScreenPreference: NSObject {

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
    var pendingAdditionalInfoCells = [MPCustomCell]()
    var approvedAdditionalInfoCells = [MPCustomCell]()
    var approvedSubHeaderCells = [MPCustomCell]()

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

    open func setApprovedSecondaryExitButton(callback: ((PaymentResult) -> Void)?, text: String) {
        self.approvedSecondaryExitButtonText = text
        self.approvedSecondaryExitButtonCallback = callback
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

    open func setPendingSecondaryExitButton(callback: ((PaymentResult) -> Void)?, text: String? = nil) {
        self.pendingSecondaryExitButtonText = text
        self.pendingSecondaryExitButtonCallback = callback
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

    open func setRejectedSecondaryExitButton(callback: ((PaymentResult) -> Void)?, text: String? = nil) {
        self.rejectedSecondaryExitButtonText = text
        self.rejectedSecondaryExitButtonCallback = callback
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

    // MARK: Custom Rows

    open func setCustomPendingCells(customCells: [MPCustomCell]) {
        self.pendingAdditionalInfoCells = customCells
    }

    open func setCustomsApprovedCell(customCells: [MPCustomCell]) {
        self.approvedAdditionalInfoCells = customCells
    }

    open func setCustomApprovedSubHeaderCell(customCells: [MPCustomCell]) {
        self.approvedSubHeaderCells = customCells
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
    open func getApprovedSecondaryButtonCallback() -> ((PaymentResult) -> Void)? {
        return approvedSecondaryExitButtonCallback
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

    open func getPendingSecondaryButtonCallback() -> ((PaymentResult) -> Void)? {
        return pendingSecondaryExitButtonCallback
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
    open func getRejectedSecondaryButtonCallback() -> ((PaymentResult) -> Void)? {
        return rejectedSecondaryExitButtonCallback
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
