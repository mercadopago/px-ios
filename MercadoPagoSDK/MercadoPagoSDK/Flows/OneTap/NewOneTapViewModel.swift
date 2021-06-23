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
        return true
    }
    
    // MARK: - Private methods
    private func getDataSource() -> [PXOneTapDto] {
        return []
    }
}
