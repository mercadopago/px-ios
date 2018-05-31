//
//  PXOneTapItemComponentProps.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 16/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXOneTapItemComponentProps {
    let collectorImage: UIImage?
    let title: String?
    let installmentAmount: Double
    let numberOfInstallments: Int?
    let totalWithoutDiscount: Double?
    let discountDescription: String?
    let discountLimit: String?
    let shouldShowArrow: Bool

    init(title: String?, collectorImage: UIImage?, numberOfInstallments: Int?, installmentAmount: Double, totalWithoutDiscount: Double?, discountDescription: String?, discountLimit: String?, shouldShowArrow: Bool = true) {
        self.collectorImage = collectorImage
        self.title = title
        self.installmentAmount = installmentAmount
        self.totalWithoutDiscount = totalWithoutDiscount
        self.discountDescription = discountDescription
        self.discountLimit = discountLimit
        self.numberOfInstallments = numberOfInstallments
        self.shouldShowArrow = shouldShowArrow
    }
}
