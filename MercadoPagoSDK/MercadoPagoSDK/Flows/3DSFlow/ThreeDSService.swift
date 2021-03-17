//
//  ThreeDSService.swift
//  MercadoPagoSDKV4
//
//  Created by Eric Ertl on 05/03/2021.
//

import Foundation

internal class ThreeDSService {
    var paymentData: PXPaymentData
    var oneTap: [PXOneTapDto]?
    var amountToPay: Double
    var siteId: String
    var pxNavigationHandler: PXNavigationHandler
    var needToShowLoading: Bool
    weak var resultHandler: ThreeDSServiceResultHandler?

    init(paymentData: PXPaymentData, oneTap: [PXOneTapDto]?, amountToPay: Double, siteId: String, pxNavigationHandler: PXNavigationHandler, needToShowLoading: Bool, resultHandler: ThreeDSServiceResultHandler) {
        self.paymentData = paymentData
        self.oneTap = oneTap
        self.amountToPay = amountToPay
        self.siteId = siteId
        self.pxNavigationHandler = pxNavigationHandler
        self.needToShowLoading = needToShowLoading
        self.resultHandler = resultHandler
    }
    
    func authorize3DS() {
        if let cardTokenID = paymentData.token?.getId(),
           let paymentMethod = paymentData.paymentMethod,
           let oneTapDto = oneTap?.first(where: {
            $0.paymentTypeId == paymentMethod.paymentTypeId && $0.paymentMethodId == paymentMethod.getId()
           }),
           let oneTapCardDto = oneTapDto.oneTapCard,
           let cardHolderName = oneTapCardDto.cardUI?.name,
           let paymentMethodId = paymentMethod.getId() {
            
            if needToShowLoading {
                self.pxNavigationHandler.presentLoading()
            }
            
            let currencyId = SiteManager.shared.getCurrency().getCurrencySymbolOrDefault()
            let decimalPlaces = SiteManager.shared.getCurrency().getDecimalPlacesOrDefault()
            let decimalSeparator = SiteManager.shared.getCurrency().getDecimalSeparatorOrDefault()
            let thousandsSeparator = SiteManager.shared.getCurrency().getThousandsSeparatorOrDefault()
            let purchaseAmount = Utils.getAmountFormatted(amount: amountToPay, thousandSeparator: thousandsSeparator, decimalSeparator: decimalSeparator, addingCurrencySymbol: nil, addingParenthesis: false)
            
            PXConfiguratorManager.threeDSProtocol.authenticate(config: PXConfiguratorManager.threeDSConfig,
                                                               cardTokenID: cardTokenID,
                                                               cardHolderName: cardHolderName,
                                                               paymentMethodId: paymentMethodId,
                                                               purchaseAmount: purchaseAmount,
                                                               currencyId: currencyId,
                                                               decimalPlaces: decimalPlaces,
                                                               decimalSeparator: decimalSeparator,
                                                               thousandsSeparator: thousandsSeparator,
                                                               siteId: siteId,
                                                               completion: { result in
                                                                switch result {
                                                                case .success(let authorized):
                                                                    authorized ? self.resultHandler?.finishFlow(threeDSAuthorization: authorized) :
                                                                                 self.resultHandler?.finishWithError(error: MPSDKError())
                                                                case .failure(_):
                                                                    self.resultHandler?.finishWithError(error: MPSDKError())
                                                                }
            })
        } else {
            resultHandler?.finishWithError(error: MPSDKError())
        }
    }
}
