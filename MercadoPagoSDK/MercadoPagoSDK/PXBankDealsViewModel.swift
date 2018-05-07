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
    func getBankDealComponentForIndexPath(_ indexPath: IndexPath) -> PXBankDealComponent {
        let bankDeal = bankDeals[indexPath.row]
        let image = ViewUtils.loadImageFromUrl(bankDeal.picture?.url)
        let placeholder = bankDeal.issuer?.name
        let expirationDateFormat = "Hasta el %@".localized
        let dateString = Utils.getFormatedStringDate(bankDeal.dateExpired!)
        let subtitle = String(format: expirationDateFormat, dateString)

        let props = PXBankDealComponentProps(image: image, placeholder: placeholder, title: bankDeal.recommendedMessage, subtitle: subtitle)
        let component = PXBankDealComponent(props: props)
        return component
    }

    func getBankDealDetailsViewControllerForIndexPath(_ indexPath: IndexPath) -> UIViewController {
        let bankDeal = bankDeals[indexPath.row]
        let viewModel = PXBankDealDetailsViewModel(bankDeal: bankDeal)
        return PXBankDealDetailsViewController(viewModel: viewModel)
    }
}
