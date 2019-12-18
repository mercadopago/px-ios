//
//  PXOfflineMethodsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2019.
//

import Foundation

final class PXOfflineMethodsViewModel {

    let paymentTypes: [PXOfflinePaymentType]

    var selectedIndexPath: IndexPath?

    init(paymentTypes: [PXOfflinePaymentType]) {
        self.paymentTypes = paymentTypes
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
        return PXOfflineMethodsCellData(title: model.name, subtitle: model.description, imageUrl: model.imageUrl, isSelected: isSelected)
    }
}
