//
//  PXPromotionLegalsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 24/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXPromotionLegalsViewModel: NSObject {

    var bankDeal: BankDeal

    public init(bankDeal: BankDeal) {
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

    

    func getLegalsText() -> String {
        return bankDeal.legals
    }
}

// MARK: - Components builders
extension PXPromotionLegalsViewModel {
//    func getPromotionCellComponent() -> PXPromotionCell {
//        let props = PXPromotionCellProps(image: <#T##UIImage?#>, title: bankDeal., subtitle: <#T##String?#>)
//    }
}
