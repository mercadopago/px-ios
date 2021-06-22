//
//  NewOneTaoViewModel.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import Foundation

final class NewOneTapViewModel {
    // MARK: - Private properties
    private let info: PXInitDTO?
    
    // MARK: - Initialization
    init(info: PXInitDTO) {
        self.info = info
    }
    
    // MARK: - Public methods
    func hasInfo() -> Bool {
        return info != nil
    }
}
