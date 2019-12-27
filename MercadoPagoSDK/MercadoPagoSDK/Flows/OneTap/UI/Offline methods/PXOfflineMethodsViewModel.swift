//
//  PXOfflineMethodsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

final class PXOfflineMethodsViewModel {

    let paymentTypes: [PXOfflinePaymentType]
    let totalAmount: Double

    var selectedIndexPath: IndexPath?

    init(paymentTypes: [PXOfflinePaymentType], totalAmount: Double) {
        self.paymentTypes = paymentTypes
        self.totalAmount = totalAmount
    }

    func getTotalTitle() -> PXText {
        let amountString = Utils.getAmountFormated(amount: totalAmount, forCurrency: SiteManager.shared.getCurrency())
        let totalString = "Total".localized + " \(amountString)"

        return PXText(message: totalString, backgroundColor: nil, textColor: nil, weight: "semi_bold")
    }

    func numberOfSections() -> Int {
        return paymentTypes.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return paymentTypes[section].paymentMethods.count
    }

    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        return 82
    }

    func dataForCellAt(_ indexPath: IndexPath) -> PXOfflineMethodsCellData {
        let isSelected: Bool = selectedIndexPath == indexPath
        let model = paymentTypes[indexPath.section].paymentMethods[indexPath.row]
        let image = ResourceManager.shared.getImageForPaymentMethod(withDescription: model.id)
        return PXOfflineMethodsCellData(title: model.name, subtitle: model.description, image: image, isSelected: isSelected)
    }

    func headerTitleForSection(_ section: Int) -> PXText? {
        return paymentTypes[section].name
    }
}
