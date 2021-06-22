//
//  PXDiscountDescriptionViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 14/07/2020.
//

import Foundation

final class PXDiscountDescriptionViewModel {

    let title: PXText
    let subtitle: PXText?
    let badge: PXDiscountInfo?
    let summary: PXText
    let description: PXText
    let legalTerms: PXDiscountInfo

    init(_ discountDescription: PXDiscountDescription) {
        self.title = discountDescription.title
        self.subtitle = discountDescription.subtitle
        self.badge = discountDescription.badge
        self.summary = discountDescription.summary
        self.description = discountDescription.description
        self.legalTerms = discountDescription.legalTerms
    }
}

// MARK: Publics
extension PXDiscountDescriptionViewModel {
    func getTitle() -> NSAttributedString? {
        return title.getAttributedString(fontSize: PXLayout.M_FONT, textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.8), backgroundColor: .clear)
    }

    func getSubtitle() -> NSAttributedString? {
        return subtitle?.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.45), backgroundColor: .clear)
    }

    func getBadgeContent() -> NSAttributedString? {
        return badge?.content.getAttributedString(fontSize: PXLayout.XXS_FONT, backgroundColor: .clear)
    }

    func getBadgeBackgroundColor() -> String? {
        return badge?.content.backgroundColor
    }

    func getBadgeUrl() -> String? {
        return badge?.url
    }

    func getSummary() -> NSAttributedString? {
        return summary.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.8), backgroundColor: .clear)
    }

    func getDescription() -> NSAttributedString? {
        return description.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.8), backgroundColor: .clear)
    }

    func getLegalTermsContent() -> NSAttributedString? {
        return legalTerms.content.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: UIColor(red: 0, green: 158, blue: 227), backgroundColor: .clear)
    }

    func getLegalTermsUrl() -> String {
        return legalTerms.url
    }
}
