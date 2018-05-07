//
//  PXPromotionLegalsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 24/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

final class PXPromotionLegalsViewModel: NSObject {

    var bankDeal: PXBankDeal

    public init(bankDeal: PXBankDeal) {
        self.bankDeal = bankDeal
        super.init()
    }

}

// MARK: - Getters
extension PXPromotionLegalsViewModel {
    func getLegalsText() -> String? {
        return bankDeal.legals
    }
}

// MARK: - Components builders
extension PXPromotionLegalsViewModel {
    func getPromotionCellComponent() -> PXPromotionCell {
        let image = ViewUtils.loadImageFromUrl(bankDeal.picture?.url)
        let placeholder = bankDeal.issuer?.name
        let expirationDateFormat = "Hasta el %@".localized
        let dateString = Utils.getFormatedStringDate(bankDeal.dateExpired!)
        let subtitle = String(format: expirationDateFormat, dateString)
        let props = PXPromotionCellProps(image: image, placeholder: placeholder, title: bankDeal.recommendedMessage, subtitle: subtitle)
        let component = PXPromotionCell(props: props)
        return component
    }
}
