import UIKit

open class ReviewScreenPreference: NSObject {

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
    fileprivate var disclaimerTextColor: UIColor = ThemeManager.shared.getTheme().noTaxAndDiscountLabelTintColor()
    fileprivate var topCustomComponent: PXCustomComponentizable?
    fileprivate var bottomCustomComponent: PXCustomComponentizable?
    
    fileprivate var itemsReview: ItemsReview = ItemsReview() //Revisar
}

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

// MARK: Collector icon.
extension ReviewScreenPreference {
    open func setCollectorIcon(image: UIImage){
        collectorIcon = image
    }
    
    open func getCollectorIcon() -> UIImage? {
        return collectorIcon
    }
}

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
    
    public func addSummaryChargeDetail(amount: Double) {
        self.addDetail(detail: SummaryItemDetail(amount: amount), type: SummaryType.CHARGE)
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
                    totalAmount = totalAmount - detailAmount
                } else {
                    totalAmount = totalAmount + detailAmount
                }
            }
        }
        return totalAmount
    }
}
