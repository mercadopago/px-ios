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

// MARK: - Logic
extension PXPromotionLegalsViewModel {
    func shouldShowCFT() -> Bool {
        return true
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
        let image = MercadoPago.getImage("financial_institution_1001")
        let props = PXPromotionCellProps(image: image, title: bankDeal.recommendedMessage, subtitle: "\(bankDeal.dateExpired)")
        let component = PXPromotionCell(props: props)
        return component
    }
}
