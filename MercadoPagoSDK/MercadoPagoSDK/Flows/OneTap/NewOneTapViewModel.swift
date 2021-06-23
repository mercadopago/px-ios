//
//  NewOneTaoViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import Foundation

final class NewOneTapViewModel {
    // MARK: - Private properties
    private let oneTapModel: OneTapModel
    
    // MARK: - Public properties
    weak var coordinator: OneTapCoordinator?
    
    
    // MARK: - Initialization
    init(
        oneTapModel: OneTapModel,
        coordinator: OneTapCoordinator? = nil
    ) {
        self.oneTapModel = oneTapModel
        self.coordinator = coordinator
    }
    
    // MARK: - Public methods
    func hasInfo() -> Bool {
        return true
    }
}
