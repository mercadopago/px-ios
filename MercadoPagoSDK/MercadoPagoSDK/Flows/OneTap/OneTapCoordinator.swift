//
//  OneTapCoordinator.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit
import MLCardForm
import AndesUI

protocol OneTapCoodinatorDelegate: AnyObject {
    func didUpdateCard(selectedCard: PXCardSliderViewModel)
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel])
    func refreshFlow(cardId: String)
    func userDidConfirmPayment(paymentData: PXPaymentData, isSplitAccountPaymentEnable: Bool)
    func updatePaymentOption(paymentMethodOption: PaymentMethodOption)
    func finishButtonAnimation()
    func closeFlow()
    func clearPaymentData()
}

final class OneTapCoordinator: BaseCoordinator {
    // MARK: - Private properties
    private let navigationController: UINavigationController
    private let oneTapViewModel: PXOneTapViewModel
    private lazy var oneTapController: PXOneTapViewController = PXOneTapViewController(viewModel: oneTapViewModel)
    
    // MARK: - Public properties
    weak var delegate: OneTapCoodinatorDelegate?
    
    // MARK: - Initialization
    init(
        navigationController: UINavigationController,
        cardViewModel: CardViewModel,
        selectedCard: PXCardSliderViewModel,
        oneTapModel: OneTapModel
    ) {
        self.navigationController = navigationController
        self.oneTapViewModel = PXOneTapViewModel(oneTapModel: oneTapModel, cardViewModel: cardViewModel, selectedCard: selectedCard)
    }
    
    // MARK: - Overrides
    override func start() {
        oneTapViewModel.coordinator = self
        oneTapController.coordinatorDelegate = self
        navigationController.pushViewController(oneTapController, animated: true)
    }
}

// MARK: - OneTapRedirects
extension OneTapCoordinator: OneTapCoordinatorActions {
    func updatePaymentOption(paymentMethodOption: PaymentMethodOption) {
        delegate?.updatePaymentOption(paymentMethodOption: paymentMethodOption)
    }
    
    func goToCardForm(cardFormParameters: CardFormParameters, initType: String) {
        let flowId = MPXTracker.sharedInstance.getFlowName() ?? "unknown"
        let builder: MLCardFormBuilder

        if let privateKey = cardFormParameters.privateKey {
            builder = MLCardFormBuilder(privateKey: privateKey, siteId: cardFormParameters.siteId, flowId: flowId, lifeCycleDelegate: self)
        } else {
            builder = MLCardFormBuilder(publicKey: cardFormParameters.publicKey, siteId: cardFormParameters.siteId, flowId: flowId, lifeCycleDelegate: self)
        }

        builder.setLanguage(Localizator.sharedInstance.getLanguage())
        builder.setExcludedPaymentTypes(cardFormParameters.excludedPaymentTypeIds)
        builder.setNavigationBarCustomColor(backgroundColor: ThemeManager.shared.navigationBar().backgroundColor, textColor: ThemeManager.shared.navigationBar().tintColor)
        var cardFormVC: UIViewController
        switch initType {
        case "webpay_tbk":
            cardFormVC = MLCardForm(builder: builder).setupWebPayController()
        default:
            builder.setAnimated(true)
            cardFormVC = MLCardForm(builder: builder).setupController()
        }
        navigationController.pushViewController(cardFormVC, animated: true)
    }
    
    func showOfflinePaymentSheet(offlineController: PXOfflineMethodsViewController) {
        let sheet = PXOfflineMethodsSheetViewController(viewController: offlineController,
                                                        offlineViewModel: offlineController.viewModel,
                                                        whiteViewHeight: PXCardSliderSizeManager.getWhiteViewHeight(viewController: oneTapController))

        offlineController.eventsDelegate = self
        navigationController.present(sheet, animated: true, completion: nil)
    }
    
    func showBottomSheet(newCard: PXOneTapNewCardDto) {
        let viewController = PXOneTapSheetViewController(newCard: newCard)
        viewController.delegate = self
        let sheet = AndesBottomSheetViewController(rootViewController: viewController)
        sheet.titleBar.text = newCard.label.message
        sheet.titleBar.textAlignment = .center
//        andesBottomSheet = sheet
        navigationController.present(sheet, animated: true, completion: nil)
    }
    
    func didUpdateCard(selectedCard: PXCardSliderViewModel) {
        delegate?.didUpdateCard(selectedCard: selectedCard)
    }
    
    func userDidUpdateCardList(cardList: [PXCardSliderViewModel]) {
        delegate?.userDidUpdateCardList(cardList: cardList)
    }
    
    func refreseInitFlow(cardId: String) {
        delegate?.refreshFlow(cardId: cardId)
    }
    
    func userDidCloseFlow() {
        delegate?.closeFlow()
    }
    
    func clearPaymentData() {
        delegate?.clearPaymentData()
    }
    
    func userDidConfirmPayment(paymentData: PXPaymentData, isSplitAccountPaymentEnable: Bool) {
        delegate?.userDidConfirmPayment(paymentData: paymentData, isSplitAccountPaymentEnable: isSplitAccountPaymentEnable)
    }
}

extension OneTapCoordinator: OfflineMethodsEventsDelegate {
    func userDidConfirm(paymentData: PXPaymentData, isSplitPayment: Bool) {
        delegate?.userDidConfirmPayment(paymentData: paymentData, isSplitAccountPaymentEnable: isSplitPayment)
    }
    
    func didFinishCheckout() {
        
    }
    
    func finishButtonAnimation() {
        delegate?.finishButtonAnimation()
    }
    
    func updatePaymentOption(paymentOption: PaymentMethodOption) {
        
    }
}

extension OneTapCoordinator: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        
    }
    
    func didFailAddCard() {
        
    }
}

extension OneTapCoordinator: PXOneTapSheetViewControllerProtocol {
    func didTapOneTapSheetOption(sheetOption: PXOneTapSheetOptionsDto) {
        
    }
}
