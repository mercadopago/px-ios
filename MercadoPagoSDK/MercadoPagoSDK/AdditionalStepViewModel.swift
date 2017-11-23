//
//  AdditionalStepViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/3/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoPXTracking

open class AdditionalStepViewModel: NSObject {

    var bundle: Bundle? = MercadoPago.getBundle()
    open var discount: DiscountCoupon?
    public var screenTitle: String
    open var screenId: String { get { return TrackingUtil.NO_SCREEN_ID } }
    open var screenName: String { get { return TrackingUtil.NO_NAME_SCREEN } }

    open var amount: Double
    open var email: String?
    open var token: CardInformationForm?
    open var paymentMethods: [PaymentMethod]
    open var cardSectionView: Updatable?
    open var cardSectionVisible: Bool
    open var totalRowVisible: Bool
    open var bankInterestWarningCellVisible: Bool
    open var dataSource: [Cellable]
    open var defaultTitleCellHeight: CGFloat = 40
    open var defaultRowCellHeight: CGFloat = 80
    open var callback: ((_ result: NSObject) -> Void)!
    open var maxFontSize: CGFloat { get { return 24 } }
    open var couponCallback: ((DiscountCoupon) -> Void)?

    open var mercadoPagoServicesAdapter: MercadoPagoServicesAdapter

    init(screenTitle: String, cardSectionVisible: Bool, cardSectionView: Updatable? = nil, totalRowVisible: Bool, showBankInsterestWarning: Bool = false, amount: Double, token: CardInformationForm?, paymentMethods: [PaymentMethod], dataSource: [Cellable], discount: DiscountCoupon? = nil, email: String? = nil, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        self.screenTitle = screenTitle
        self.amount = amount
        self.token = token
        self.paymentMethods = paymentMethods
        self.cardSectionVisible = cardSectionVisible
        self.cardSectionView = cardSectionView
        self.totalRowVisible = totalRowVisible
        self.bankInterestWarningCellVisible = showBankInsterestWarning
        self.dataSource = dataSource
        self.discount = discount
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

    func showDiscountSection() -> Bool {
        return false
    }

    func showTotalRow() -> Bool {
        return totalRowVisible && !showDiscountSection()
    }

    func showAmountDetailRow() -> Bool {
        return showTotalRow() || showDiscountSection()
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
        case Sections.amountDetail.rawValue:
            return showAmountDetailRow() ? 1 : 0
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

        } else if isDiscountCellFor(indexPath: indexPath) || isTotalCellFor(indexPath: indexPath) {
            return self.getAmountDetailCellHeight(indexPath: indexPath)

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

    func getAmountDetailCellHeight(indexPath: IndexPath) -> CGFloat {
        if isDiscountCellFor(indexPath: indexPath) {
            return DiscountBodyCell.HEIGHT
        } else if isTotalCellFor(indexPath: indexPath) {
            return 42
        }
        return 0
    }

    func isDiscountCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.amountDetail.rawValue && showDiscountSection()
    }

    func isTotalCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.amountDetail.rawValue && showTotalRow()
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

    public enum CardSectionCells: Int {
        case card = 0
        case bankInterestWarning = 1
    }

    public enum Sections: Int {
        case title = 0
        case card = 1
        case amountDetail = 2
        case body = 3
    }

    func track() {
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName)
    }

}

class IssuerAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    init(amount: Double, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(screenTitle: "¿Quién emitió tu tarjeta?".localized, cardSectionVisible: true, cardSectionView: CardFrontView(frame: self.cardViewRect), totalRowVisible: false, amount: amount, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_CARD_FORM_ISSUERS } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_CARD_FORM + TrackingUtil.CARD_ISSUER} }

    override func track() {
        let metadata = [TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentMethods[0]._id, TrackingUtil.METADATA_PAYMENT_TYPE_ID: paymentMethods[0].paymentTypeId]
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName, metadata: metadata)
    }

}

class PayerCostAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    init(amount: Double, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], discount: DiscountCoupon? = nil, email: String? = nil, mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(screenTitle: "¿En cuántas cuotas?".localized, cardSectionVisible: true, cardSectionView: CardFrontView(frame: self.cardViewRect), totalRowVisible: true, showBankInsterestWarning: true, amount: amount, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, discount: discount, email: email, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_CARD_FORM_INSTALLMENTS } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_CARD_FORM + TrackingUtil.CARD_INSTALLMENTS } }

    override func getDefaultRowCellHeight() -> CGFloat {
        if AdditionalStepCellFactory.needsCFTPayerCostCell(payerCost: dataSource[0] as! PayerCost) {
            return 86
        } else {
            return 60
        }
    }

    override func showDiscountSection() -> Bool {
        return MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable()
    }

    override func isBankInterestCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.row == CardSectionCells.bankInterestWarning.rawValue && indexPath.section == Sections.card.rawValue && showBankInsterestCell()
    }

    override func track() {
        let metadata = [TrackingUtil.METADATA_PAYMENT_METHOD_ID: paymentMethods[0]._id]
        MPXTracker.trackScreen(screenId: screenId, screenName: screenName, metadata: metadata)
    }

}

class CardTypeAdditionalStepViewModel: AdditionalStepViewModel {

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    override open var screenName: String { get { return TrackingUtil.SCREEN_NAME_PAYMENT_TYPES } }
    override open var screenId: String { get { return TrackingUtil.SCREEN_ID_PAYMENT_TYPES } }

    init(amount: Double, token: CardInformationForm?, paymentMethods: [PaymentMethod], dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(screenTitle: "¿Qué tipo de tarjeta es?".localized, cardSectionVisible: true, cardSectionView:CardFrontView(frame: self.cardViewRect), totalRowVisible: false, amount: amount, token: token, paymentMethods: paymentMethods, dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }
}

class FinancialInstitutionAdditionalStepViewModel: AdditionalStepViewModel {

    override open var screenName: String { get { return "FINANCIAL_INSTITUTION" } }

    init(amount: Double, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(screenTitle: "¿Cuál es tu banco?".localized, cardSectionVisible: false, cardSectionView: nil, totalRowVisible: false, amount: amount, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

}

class EntityTypeAdditionalStepViewModel: AdditionalStepViewModel {

    override var maxFontSize: CGFloat { get { return 21 } }

    let cardViewRect = CGRect(x: 0, y: 0, width: 100, height: 30)

    override open var screenName: String { get { return "ENTITY_TYPE" } }

    init(amount: Double, token: CardInformationForm?, paymentMethod: PaymentMethod, dataSource: [Cellable], mercadoPagoServicesAdapter: MercadoPagoServicesAdapter) {
        super.init(screenTitle: "¿Cuál es el tipo de persona?".localized, cardSectionVisible: true, cardSectionView:IdentificationCardView(frame: self.cardViewRect), totalRowVisible: false, amount: amount, token: token, paymentMethods: [paymentMethod], dataSource: dataSource, mercadoPagoServicesAdapter: mercadoPagoServicesAdapter)
    }

}
