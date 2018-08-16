//
//  AdditionalStepViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/3/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoPXTrackingV4
import MercadoPagoServicesV4

/** :nodoc: */
open class AdditionalStepViewModel: NSObject {

    /// :nodoc:
    var bundle: Bundle? = MercadoPago.getBundle()
    /// :nodoc:
    public var screenTitle: String
    /// :nodoc:
    open var screenId: String { return TrackingUtil.NO_SCREEN_ID }
    /// :nodoc:
    open var screenName: String { return TrackingUtil.NO_NAME_SCREEN }
    /// :nodoc:
    open var email: String?
    /// :nodoc:
    open var token: CardInformationForm?
    /// :nodoc:
    open var paymentMethods: [PaymentMethod]
    /// :nodoc:
    open var cardSectionView: Updatable?
    /// :nodoc:
    open var cardSectionVisible: Bool
    /// :nodoc:
    open var totalRowVisible: Bool
    /// :nodoc:
    open var bankInterestWarningCellVisible: Bool
    /// :nodoc:
    open var dataSource: [Cellable]
    /// :nodoc:
    open var defaultTitleCellHeight: CGFloat = 40
    /// :nodoc:
    open var defaultRowCellHeight: CGFloat = 80
    /// :nodoc:
    open var callback: ((_ result: NSObject) -> Void)!
    /// :nodoc:
    open var maxFontSize: CGFloat { return 24 }
    /// :nodoc:
    open var couponCallback: ((PXDiscount) -> Void)?

    let amountHelper: PXAmountHelper

    /// :nodoc:
    open var mercadoPagoServicesAdapter: MercadoPagoServicesAdapter

    /// :nodoc:
    init(amountHelper: PXAmountHelper, screenTitle: String, cardSectionVisible: Bool, cardSectionView: Updatable? = nil, totalRowVisible: Bool, showBankInsterestWarning: Bool = false, token: CardInformationForm?, paymentMethods: [PaymentMethod], dataSource: [Cellable], email: String? = nil, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        self.amountHelper = amountHelper
        self.screenTitle = screenTitle
        self.token = token
        self.paymentMethods = paymentMethods
        self.cardSectionVisible = cardSectionVisible
        self.cardSectionView = cardSectionView
        self.totalRowVisible = totalRowVisible
        self.bankInterestWarningCellVisible = showBankInsterestWarning
        self.dataSource = dataSource
        self.email = email
        self.mercadoPagoServicesAdapter = mercadoPagoServicesAdapter
    }

    func showCardSection() -> Bool {
        return cardSectionVisible
    }

    func showPayerCostDescription() -> Bool {
        return MercadoPagoCheckout.showPayerCostDescription()
    }

    func showBankInsterestCell() -> Bool {
        return self.bankInterestWarningCellVisible && MercadoPagoCheckout.showBankInterestWarning()
    }

    func showFloatingTotalRow() -> Bool {
        return false
    }

    func getScreenName() -> String {
        return screenName
    }

    func getScreenId() -> String {
        return screenId
    }

    func getTitle() -> String {
        return screenTitle
    }

    func numberOfSections() -> Int {
        return 4
    }

    func numberOfRowsInSection(section: Int) -> Int {
        switch section {

        case Sections.title.rawValue:
            return 1
        case Sections.card.rawValue:
            var rows: Int = showCardSection() ? 1 : 0
            rows = showBankInsterestCell() ? rows + 1 : rows
            return rows
        case Sections.body.rawValue:
            return numberOfCellsInBody()
        default:
            return 0
        }
    }

    func numberOfCellsInBody() -> Int {
        return dataSource.count
    }

    func heightForRowAt(indexPath: IndexPath) -> CGFloat {

        if isTitleCellFor(indexPath: indexPath) {
            return getTitleCellHeight()

        } else if isCardCellFor(indexPath: indexPath) {
            return self.getCardCellHeight()

        } else if isBankInterestCellFor(indexPath: indexPath) {
            return self.getBankInterestWarningCellHeight()

        } else if isBodyCellFor(indexPath: indexPath) {
            return self.getDefaultRowCellHeight()
        }
         return 0
    }

    func getCardSectionView() -> Updatable? {
        return cardSectionView
    }

    func getTitleCellHeight() -> CGFloat {
        return defaultTitleCellHeight
    }

    func getCardCellHeight() -> CGFloat {
        return UIScreen.main.bounds.width * 0.50
    }

    func getDefaultRowCellHeight() -> CGFloat {
        return defaultRowCellHeight
    }

    func getBankInterestWarningCellHeight() -> CGFloat {
        return BankInsterestTableViewCell.cellHeight
    }

    func isTitleCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.title.rawValue
    }

    func isCardCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.row == CardSectionCells.card.rawValue && indexPath.section == Sections.card.rawValue && showCardSection()
    }

    func isBankInterestCellFor(indexPath: IndexPath) -> Bool {
        return false
    }

    func isBodyCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.body.rawValue && indexPath.row < numberOfCellsInBody()
    }

    /// :nodoc:
    public enum CardSectionCells: Int {
        case card = 0
        case bankInterestWarning = 1
    }

    /// :nodoc:
    public enum Sections: Int {
        case title = 0
        case card = 1
        case body = 2
    }

    func track() {
        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName)
    }

}

class IssuerAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    /// :nodoc:
    init(amountHelper: PXAmountHelper, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(amountHelper: amountHelper, screenTitle: "¿Quién emitió tu tarjeta?".localized, cardSectionVisible: true, cardSectionView: CardFrontView(frame: self.cardViewRect), totalRowVisible: false, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    /// :nodoc:
    override open var screenName: String { return TrackingUtil.SCREEN_NAME_CARD_FORM_ISSUERS }
    /// :nodoc:
    override open var screenId: String { return TrackingUtil.SCREEN_ID_CARD_FORM + TrackingUtil.CARD_ISSUER }

    override func track() {
        let metadata: [String: String] = [TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentMethods[0].paymentMethodId, TrackingUtil.METADATA_PAYMENT_TYPE_ID: paymentMethods[0].paymentTypeId]
        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName, properties: metadata)
    }

}

class PayerCostAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    init(amountHelper: PXAmountHelper, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], email: String? = nil, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(amountHelper: amountHelper, screenTitle: "¿En cuántas cuotas?".localized, cardSectionVisible: true, cardSectionView: CardFrontView(frame: self.cardViewRect), totalRowVisible: true, showBankInsterestWarning: true, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, email: email, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    /// :nodoc:
    override open var screenName: String { return TrackingUtil.SCREEN_NAME_CARD_FORM_INSTALLMENTS }
    /// :nodoc:
    override open var screenId: String { return TrackingUtil.SCREEN_ID_CARD_FORM + TrackingUtil.CARD_INSTALLMENTS }

    override func showFloatingTotalRow() -> Bool {
        return true
    }

    override func getDefaultRowCellHeight() -> CGFloat {
        if AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: dataSource[0] as! PayerCost) {
            return 86
        } else {
            return 60
        }
    }

    override func isBankInterestCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.row == CardSectionCells.bankInterestWarning.rawValue && indexPath.section == Sections.card.rawValue && showBankInsterestCell()
    }

    override func track() {
        let metadata: [String: String] = [TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentMethods[0].paymentMethodId]
        MPXTracker.sharedInstance.trackScreen(screenId: screenId, screenName: screenName, properties: metadata)
    }

}

class CardTypeAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    /// :nodoc:
    override open var screenName: String { return TrackingUtil.SCREEN_NAME_PAYMENT_TYPES }
    /// :nodoc:
    override open var screenId: String { return TrackingUtil.SCREEN_ID_PAYMENT_TYPES }

    init(amountHelper: PXAmountHelper, token: CardInformationForm?, paymentMethods: [PaymentMethod], dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(amountHelper: amountHelper, screenTitle: "¿Qué tipo de tarjeta es?".localized, cardSectionVisible: true, cardSectionView: CardFrontView(frame: self.cardViewRect), totalRowVisible: false, token: token, paymentMethods: paymentMethods, dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }
}

class FinancialInstitutionViewModel: AdditionalStepViewModel {

    /// :nodoc:
    override open var screenName: String { return "FINANCIAL_INSTITUTION" }

    init(amountHelper: PXAmountHelper, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(amountHelper: amountHelper, screenTitle: "¿Cuál es tu banco?".localized, cardSectionVisible: false, cardSectionView: nil, totalRowVisible: false, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

}

class EntityTypeViewModel: AdditionalStepViewModel {

    override var maxFontSize: CGFloat { return 21 }

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    /// :nodoc:
    override open var screenName: String { return "ENTITY_TYPE" }

    init(amountHelper: PXAmountHelper, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(amountHelper: amountHelper, screenTitle: "¿Cuál es el tipo de persona?".localized, cardSectionVisible: true, cardSectionView: IdentificationCardView(frame: self.cardViewRect), totalRowVisible: false, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

}
