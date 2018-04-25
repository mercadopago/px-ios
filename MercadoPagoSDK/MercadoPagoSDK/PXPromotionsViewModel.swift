//
//  PXPromotionsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

final class PXPromotionsViewModel: NSObject {

    var bankDeals: [PXBankDeal]

    public init(bankDeals: [PXBankDeal]) {
        self.bankDeals = bankDeals
        super.init()
    }
}

// MARK: - Logic
extension PXPromotionsViewModel {
    func getAmountOfCells() -> Int {
        return self.bankDeals.count
    }
}

// MARK: - Components builders
extension PXPromotionsViewModel {
    func getPromotionCellComponentForIndexPath(_ indexPath: IndexPath) -> PXPromotionCell {
        let bankDeal = bankDeals[indexPath.row]
        let image = MercadoPago.getImage("financial_institution_1001")

        let expirationDateFormat = "Hasta el %@".localized
        let dateString = Utils.getFormatedStringDate(bankDeal.dateExpired!)
        let subtitle = String(format: expirationDateFormat, dateString)

        let props = PXPromotionCellProps(image: image, title: bankDeal.recommendedMessage, subtitle: subtitle)
        let component = PXPromotionCell(props: props)
        return component
    }
}

