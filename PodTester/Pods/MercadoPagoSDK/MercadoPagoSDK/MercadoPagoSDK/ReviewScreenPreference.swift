//
//  ReviewScreenPreference.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/14/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

open class ReviewScreenPreference: NSObject {

    private var title = "Confirma tu compra".localized
    private var productsTitle = "Productos".localized
    private var confirmButtonText = "Confirmar".localized
    private var cancelButtonText = "Cancelar Pago".localized
	private var shouldDisplayChangeMethodOption = true
    
    private var summaryRows = [SummaryRow]()
    
    internal static var additionalInfoCells = [MPCustomCell]()
    internal static var customItemCells = [MPCustomCell]()
    
    open func setTitle(title : String){
        self.title = title
    }
    
    open func getTitle() -> String {
        return title
    }
    
    open func setProductsDetail(productsTitle : String) {
        self.productsTitle = productsTitle
    }
    
    open func getProductsTitle() -> String {
        return self.productsTitle
    }
    
    open func setConfirmButtonText(confirmButtonText : String){
        self.confirmButtonText = confirmButtonText
    }
    
    open func getConfirmButtonText() -> String {
        return confirmButtonText
    }
	
    open func setCancelButtonText(cancelButtonText : String){
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
    
    open func setSummaryRows(summaryRows: [SummaryRow]) {
        self.summaryRows = summaryRows
    }
    
    open func getSummaryRows() -> [SummaryRow]{
        return summaryRows
    }
	
    open static func setCustomItemCell(customCell : [MPCustomCell]) {
        ReviewScreenPreference.customItemCells = customCell
    }
    
    open static func setAddionalInfoCells(customCells : [MPCustomCell]) {
        ReviewScreenPreference.additionalInfoCells = customCells
    }
    
    open static func clear() {
        ReviewScreenPreference.customItemCells = [MPCustomCell]()
        ReviewScreenPreference.additionalInfoCells = [MPCustomCell]()
    }
    
    
    
}
