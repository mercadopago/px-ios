//
//  InstallmentViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 29/06/21.
//

import Foundation

protocol InstallmentDelegate: AnyObject {
    
}

final class InstallmentViewModel {
    // MARK: - Private properties
    private let installmentsRowMessageFontSize = PXLayout.XS_FONT
    private var cards: [PXCardSliderViewModel]
    private var installMents: [PXOneTapInstallmentInfoViewModel] {
        return feedInstallments()
    }
    
    // MARK: - Initialization
    init(cards: [PXCardSliderViewModel]) {
        self.cards = cards
    }
    
    // MARK: - Private merthods
    private func feedInstallments() -> [PXOneTapInstallmentInfoViewModel] {
        var model: [PXOneTapInstallmentInfoViewModel] = []
        for card in cards {
            guard let selectedApplication = card.getSelectedApplication() else { return model }
            
            let payerCost = selectedApplication.payerCost
            let selectedPayerCost = selectedApplication.selectedPayerCost
            let installment = PXInstallment(issuer: nil, payerCosts: payerCost, paymentMethodId: nil, paymentTypeId: nil)

            let emptyMessage = "".toAttributedString()
            let disabledMessage: NSAttributedString = selectedApplication.status.mainMessage?.getAttributedString(fontSize: installmentsRowMessageFontSize, textColor: ThemeManager.shared.getAccentColor()) ?? emptyMessage

            let shouldShowInstallmentsHeader = card.shouldShowInstallmentsHeader()

            if selectedApplication.status.isDisabled() {
                let disabledInfoModel = PXOneTapInstallmentInfoViewModel(text: disabledMessage, installmentData: nil, selectedPayerCost: nil, shouldShowArrow: false, status: selectedApplication.status, benefits: selectedApplication.benefits, shouldShowInstallmentsHeader: shouldShowInstallmentsHeader)
                model.append(disabledInfoModel)
            } else if !selectedApplication.status.isUsable() {
                let disabledInfoModel = PXOneTapInstallmentInfoViewModel(text: emptyMessage, installmentData: nil, selectedPayerCost: nil, shouldShowArrow: false, status: selectedApplication.status, benefits: selectedApplication.benefits, shouldShowInstallmentsHeader: shouldShowInstallmentsHeader)
                model.append(disabledInfoModel)
            } else if selectedApplication.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
                // If it's debit and has split, update split message
                if let amountToPay = selectedApplication.selectedPayerCost?.totalAmount {
                    let displayMessage = getSplitMessageForDebit(amountToPay: amountToPay)
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: displayMessage, installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShowArrow: selectedApplication.shouldShowArrow, status: selectedApplication.status, benefits: selectedApplication.benefits, shouldShowInstallmentsHeader: shouldShowInstallmentsHeader)
                    model.append(installmentInfoModel)
                }

            } else {
                if let displayMessage = selectedApplication.displayMessage {
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: displayMessage, installmentData: installment, selectedPayerCost: selectedPayerCost, shouldShowArrow: selectedApplication.shouldShowArrow, status: selectedApplication.status, benefits: selectedApplication.benefits, shouldShowInstallmentsHeader: shouldShowInstallmentsHeader)
                    model.append(installmentInfoModel)
                } else {
                    let isDigitalCurrency: Bool = card.getCreditsViewModel() != nil
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(
                        text: getInstallmentInfoAttrText(
                            selectedPayerCost,
                            isDigitalCurrency,
                            interestFreeConfig: selectedApplication.benefits?.interestFree),
                        installmentData: installment,
                        selectedPayerCost: selectedPayerCost,
                        shouldShowArrow: selectedApplication.shouldShowArrow,
                        status: selectedApplication.status,
                        benefits: selectedApplication.benefits,
                        shouldShowInstallmentsHeader: shouldShowInstallmentsHeader
                    )
                    model.append(installmentInfoModel)
                }
            }
        }
        return model
//        return []
    }
    
    private func getInstallmentInfoAttrText(_ payerCost: PXPayerCost?, _ isDigitalCurrency: Bool = false, interestFreeConfig: PXInstallmentsConfiguration?) -> NSMutableAttributedString {
        let text: NSMutableAttributedString = NSMutableAttributedString(string: "")

        if let payerCostData = payerCost {
            // First attr
            let currency = SiteManager.shared.getCurrency()
            let firstAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
            let amountDisplayStr = Utils.getAmountFormated(amount: payerCostData.installmentAmount, forCurrency: currency).trimmingCharacters(in: .whitespaces)
            let firstText = "\(payerCostData.installments)x \(amountDisplayStr)"
            let firstAttributedString = NSAttributedString(string: firstText, attributes: firstAttributes)
            text.append(firstAttributedString)

            // Second attr
            if let interestFreeConfig = interestFreeConfig, interestFreeConfig.appliedInstallments.contains(payerCostData.installments), let rowMessage = interestFreeConfig.installmentRow?.getAttributedString(fontSize: installmentsRowMessageFontSize) {
                text.append(String.SPACE.toAttributedString())
                text.append(rowMessage)
            }

            // Third attr
            if let interestRate = payerCostData.interestRate,
                let thirdAttributedString = interestRate.getAttributedString(fontSize: installmentsRowMessageFontSize) {
                text.appendWithSpace(thirdAttributedString)
            }
        }
        return text
    }
    
    private func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        var amount: String = ""
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]

        amount = Utils.getAmountFormated(amount: amountToPay, forCurrency: SiteManager.shared.getCurrency())
        return NSAttributedString(string: amount, attributes: attributes)
    }
}
