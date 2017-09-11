//
//  ReviewScreenPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

open class ReviewScreenPreference: NSObject {

    private var title = "Revisa tu pago".localized
    private var confirmButtonText = "Confirmar".localized
    private var cancelButtonText = "Cancelar Pago".localized
	private var shouldDisplayChangeMethodOption = true
    var details : [SummaryType:SummaryDetail] = [SummaryType:SummaryDetail]()
    var disclaimer : String?
    var disclaimerColor : UIColor = UIColor.mpGreenishTeal()
    var showSubitle : Bool = false
    let summaryTitles : [SummaryType:String] = [SummaryType.PRODUCT : "Producto".localized,SummaryType.ARREARS : "Mora".localized,SummaryType.CHARGE : "Cargos".localized,
                                                            SummaryType.DISCOUNT : "Descuentos".localized, SummaryType.INTEREST : "Intereses".localized,SummaryType.TAXES : "Impuestos".localized, SummaryType.SHIPPING : "Envio".localized]
    private var itemsReview : ItemsReview = ItemsReview()

    var additionalInfoCells = [MPCustomCell]()
    var customItemCells = [MPCustomCell]()

    open func setTitle(title: String) {
        self.title = title
    }

    open func getTitle() -> String {
        return title
    }

    open func setConfirmButtonText(confirmButtonText: String) {
        self.confirmButtonText = confirmButtonText
    }

    open func getConfirmButtonText() -> String {
        return confirmButtonText
    }

    open func setCancelButtonText(cancelButtonText: String) {
        self.cancelButtonText = cancelButtonText
    }

    open func getCancelButtonTitle() -> String {
        return cancelButtonText
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

}
