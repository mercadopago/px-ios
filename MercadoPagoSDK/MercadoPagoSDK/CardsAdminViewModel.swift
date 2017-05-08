//
//  CardsAdminViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 4/20/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class CardsAdminViewModel: NSObject {

    var cards: [Card]?
    var customerId: String?
    var extraOptionTitle: String?
    var titleScreen = "¿Con qué tarjeta?".localized
    var loadingCards = true

   public  init(cards: [Card]? = nil, extraOptionTitle: String? = nil) {
        self.cards = cards
        self.extraOptionTitle = extraOptionTitle
    }

    func shouldGetCustomerCardsInfo() -> Bool {
        return cards == nil
    }

    func numberOfOptions() -> Int {
        if let _ = self.extraOptionTitle {
            if let cards = cards {
                return cards.count + 1
            } else {
                return 1
            }
        } else {
            if let cards = cards {
                return cards.count
            } else {
                return 0
            }
        }
    }

    func setTitle(title: String) {
        self.titleScreen = title
    }

    func calculateHeight(indexPath: IndexPath, numberOfCells: Int) -> CGFloat {
        if numberOfCells == 0 {
            return 0
        }

        let section: Int
        let row = indexPath.row
        if row % 2 == 1 {
            section = (row - 1) / 2
        } else {
            section = row / 2
        }
        let index1 = (section  * 2)
        let index2 = (section  * 2) + 1

        if index1 + 1 > numberOfCells {
            return 0
        }

        let height1 = heightOfItem(indexItem: index1)

        if index2 + 1 > numberOfCells {
            return height1
        }

        let height2 = heightOfItem(indexItem: index2)

        return height1 > height2 ? height1 : height2

    }

    func isHeaderSection(section: Int) -> Bool {
        return section == 0
    }
    func isCardsSection(section: Int) -> Bool {

        return section == 1
    }
    fileprivate let itemsPerRow: CGFloat = 2

    var sectionHeight: CGSize?

    func maxHegithRow(indexPath: IndexPath) -> CGFloat {
        guard let cards = self.cards else {
            return 0
        }
        return self.calculateHeight(indexPath: indexPath, numberOfCells: cards.count)
    }

    func heightOfItem(indexItem: Int) -> CGFloat {
        guard let cards = self.cards else {
            return 0
        }
        return PaymentSearchCollectionViewCell.totalHeight(drawablePaymentOption : cards[indexItem])
    }
    func numberOfSections() -> Int {
        if self.loadingCards {
            return 0
        }
        return 2
    }

    public func numberOfItemsInSection (section: Int) -> Int {
        if (self.loadingCards) {
            return 0
        }
        if (self.isHeaderSection(section: section)) {
            return 1
        }
        return self.numberOfOptions()

    }

    public func sizeForItemAt (indexPath: IndexPath) -> CGSize {

        let paddingSpace = CGFloat(32.0)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let availableWidth = screenWidth - paddingSpace

        let titleCellHeight: CGFloat = 82.0
        if self.isHeaderSection(section: indexPath.section) {
            return CGSize(width : screenWidth, height : titleCellHeight)
        }
        let widthPerItem = availableWidth / self.itemsPerRow
        return CGSize(width: widthPerItem, height: self.maxHegithRow(indexPath:indexPath)  )
    }

    func isCardItemFor(indexPath: IndexPath) -> Bool {
        guard let cards = cards else {
            return false
        }
        if !self.isCardsSection(section: indexPath.section) {
            return false
        } else if cards.count > indexPath.row {
            return true
        } else {
            return false
        }
    }

    func isExtraOptionItemFor(indexPath: IndexPath) -> Bool {
        guard let cards = cards else {
            return ( (self.isCardsSection(section: indexPath.section)) && (self.extraOptionTitle != nil) )
        }

        if !self.isCardsSection(section: indexPath.section) {
            return false
        } else if cards.count > indexPath.row {
            return false
        } else {
            return (self.extraOptionTitle != nil)
        }
    }

}
