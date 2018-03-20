//
//  ReviewScreenPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

open class ReviewScreenPreference: NSObject {

    private var title = "Revisa si está todo bien"
    private var confirmButtonText = "Pagar"
    private var cancelButtonText = "Cancelar Pago"
	private var shouldDisplayChangeMethodOption = true
    var details: [SummaryType: SummaryDetail] = [SummaryType: SummaryDetail]()
    var disclaimer: String?
    var disclaimerColor: UIColor = ThemeManager.shared.getTheme().highlightedLabelTintColor()
    var showSubitle: Bool = false
    let summaryTitles: [SummaryType: String] = [SummaryType.PRODUCT: "Producto".localized_temp, SummaryType.ARREARS: "Mora".localized_temp, SummaryType.CHARGE: "Cargos".localized_temp,
                                                            SummaryType.DISCOUNT: "Descuentos".localized_temp, SummaryType.TAXES: "Impuestos".localized_temp, SummaryType.SHIPPING: "Envío".localized_temp]
    private var itemsReview: ItemsReview = ItemsReview()

    var additionalInfoCells = [MPCustomCell]()
    var customItemCells = [MPCustomCell]()

    open func setTitle(title: String) {
        self.title = title
    }

    open func getTitle() -> String {
        return title.localized_temp
    }

    open func setConfirmButtonText(confirmButtonText: String) {
        self.confirmButtonText = confirmButtonText
    }

    open func getConfirmButtonText() -> String {
        return confirmButtonText.localized_temp
    }

    open func setCancelButtonText(cancelButtonText: String) {
        self.cancelButtonText = cancelButtonText
    }

    open func getCancelButtonTitle() -> String {
        return cancelButtonText.localized_temp
    }

	open func isChangeMethodOptionEnabled() -> Bool {
		return shouldDisplayChangeMethodOption
	}

	open func disableChangeMethodOption() {
		self.shouldDisplayChangeMethodOption = false
	}

	open func enableChangeMethodOption() {
		self.shouldDisplayChangeMethodOption = true
	}

    open func setCustomItemCell(customCell: [MPCustomCell]) {
        self.customItemCells = customCell
    }

    open func setAddionalInfoCells(customCells: [MPCustomCell]) {
        self.additionalInfoCells = customCells
    }

    static let DEFAULT_AMOUNT_TITLE = "Precio Unitario: ".localized_temp
    static let  DEFAULT_QUANTITY_TITLE = "Cantidad: ".localized_temp
    var shouldShowQuantityRow: Bool = true
    open func hideQuantityRow() {
        self.shouldShowQuantityRow = false
    }
    open func showQuantityRow() {
        self.shouldShowQuantityRow = true
    }
    var shouldShowAmountTitle: Bool = true
    open func hideAmountTitle() {
        self.shouldShowAmountTitle = false
    }
    open func showAmountTitle() {
        self.shouldShowAmountTitle = true
    }
    var quantityTitle = DEFAULT_QUANTITY_TITLE
    open func setQuantityTitle(title: String ) {
        if title.isEmpty {
            self.hideQuantityRow()
        }
        self.quantityTitle = title
    }
    open func getQuantityTitle() -> String {
        return quantityTitle
    }
    var amountTitle = DEFAULT_AMOUNT_TITLE
    open func setAmountTitle(title: String ) {
        self.amountTitle = title
    }
    open func getAmountTitle() -> String {
        return amountTitle
    }
    open func clearSummaryDetails() {
        self.details = [SummaryType: SummaryDetail]()
    }
}
