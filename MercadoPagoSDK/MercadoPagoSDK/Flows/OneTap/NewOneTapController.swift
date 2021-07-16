//
//  NewOneTapController.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 22/06/21.
//

import UIKit

final class NewOneTapController: BaseViewController {
    // MARK: - Private properties
    private let viewModel: CardViewModel
    
    // MARK: - Initialization
    init(viewModel: CardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
