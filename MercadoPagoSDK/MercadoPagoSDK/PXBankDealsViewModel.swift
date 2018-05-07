//
//  PXBankDealsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MercadoPagoServices

final class PXBankDealsViewModel: NSObject {

    var bankDeals: [PXBankDeal]

    public init(bankDeals: [PXBankDeal]) {
        self.bankDeals = bankDeals
        super.init()
    }
}

// MARK: - Logic
extension PXBankDealsViewModel {
    func getAmountOfCells() -> Int {
        return self.bankDeals.count
    }
}

// MARK: - Components builders
extension PXBankDealsViewModel {
    func getPromotionCellComponentForIndexPath(_ indexPath: IndexPath) -> PXPromotionCell {
        let bankDeal = bankDeals[indexPath.row]
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

