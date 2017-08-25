//
//  ShoppingReviewPreference.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/22/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class ShoppingReviewPreference: NSObject {

    static let DEFAULT_ONE_WORD_TITLE = "Productos".localized
    static let DEFAULT_QUANTITY_TITLE = "Cantidad : ".localized
    static let DEFAULT_AMOUNT_TITLE = "Precio Unitario : ".localized
    var shouldShowQuantityRow = true
    var shouldShowAmountTitle = true
    private var oneWordDescription = DEFAULT_ONE_WORD_TITLE
    private var quantityTitle = DEFAULT_QUANTITY_TITLE
    private var amountTitle = DEFAULT_AMOUNT_TITLE

    public func hideQuantityRow() {
        self.shouldShowQuantityRow = false
    }
    public func showQuantityRow() {
        self.shouldShowQuantityRow = true
    }
    public func showAmountTitle() {
        self.shouldShowAmountTitle = true
    }
    public func hideAmountTitle() {
        self.shouldShowAmountTitle = false
    }
    public func setOneWordDescription(oneWordDescription: String) {
        if oneWordDescription.characters.count <= 0 {
            return
        }
        if let firstWord = oneWordDescription.components(separatedBy: " ").first {
          self.oneWordDescription = firstWord
        }else {
          self.oneWordDescription = oneWordDescription
        }

    }
    public func setQuantityTitle(quantityTitle: String) {
        if quantityTitle.characters.count <= 0 {
            self.hideQuantityRow()
        }
        self.quantityTitle = quantityTitle
    }
    public func setAmountTitle(amountTitle: String) {
        if amountTitle.characters.count <= 0 {
            self.hideAmountTitle()
        }
        self.amountTitle = amountTitle
    }
    public func getOneWordDescription() -> String {
        return self.oneWordDescription
    }
    public func getQuantityTitle() -> String {
        return self.quantityTitle
    }
    public func getAmountTitle() -> String {
        return self.amountTitle
    }
}
