//
//  NewOneTaoViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

protocol OneTapRedirects: AnyObject {
    func goToCongrats()
    func goToBiometric()
    func goToCVV()
    func goToCardForm()
}

final class NewOneTapViewModel {
    // MARK: - Private properties
    private let oneTapModel: OneTapModel
    private var dataSource: [PXOneTapDto] {
        return getDataSource()
    }
    
    // MARK: - Public properties
    weak var coordinator: OneTapRedirects?
    
    // MARK: - Initialization
    init(
        oneTapModel: OneTapModel,
        coordinator: OneTapRedirects? = nil
    ) {
        self.oneTapModel = oneTapModel
        self.coordinator = coordinator
    }
    
    // MARK: - Public methods
    func hasInfo() -> Bool {
        return getDataSource().count > 1
    }
    
    // MARK: - Private methods
    private func getDataSource() -> [PXOneTapDto] {
        guard let expressData = oneTapModel.expressData else { return [] }
        return rearrangeDisabledOption(expressData, disabledOption: oneTapModel.disabledOption)
    }
    
    private func rearrangeDisabledOption(_ oneTapNodes: [PXOneTapDto], disabledOption: PXDisabledOption?) -> [PXOneTapDto] {
        guard let disabledOption = disabledOption else {return oneTapNodes}
        var rearrangedNodes = [PXOneTapDto]()
        var disabledNode: PXOneTapDto?
        for node in oneTapNodes {
            if disabledOption.isCardIdDisabled(cardId: node.oneTapCard?.cardId) || disabledOption.isPMDisabled(paymentMethodId: node.paymentMethodId) {
                disabledNode = node
            } else {
                rearrangedNodes.append(node)
            }
        }

        if let disabledNode = disabledNode {
            rearrangedNodes.append(disabledNode)
        }
        return rearrangedNodes
    }
    
    // MARK: - Public methods
    func getNumberOfIntens() -> Int {
        return getDataSource().count
    }
    
//    func getSelectedCard(cardId: String?) -> PXOneTapDto {
//        return oneTapModel.expressData?.filter { $0.ca }
//    }
}
