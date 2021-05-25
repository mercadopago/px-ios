//
//  ActionView.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 14/05/21.
//

import UIKit

protocol ActionViewDelegate: class {
    func didTapOnActionButton(action: PXInstructionAction?)
}

final class ActionView: UIView {
    // MARK: - Private properties
    private weak var delegate: ActionViewDelegate?
    private let action: PXInstructionAction?
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.ml_semiboldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor(red: 52, green: 131, blue: 250), for: .normal)
        button.setTitle(action?.label, for: .normal)
        button.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(action: PXInstructionAction?, delegate: ActionViewDelegate?) {
        self.action = action
        self.delegate = delegate
        super.init(frame: .zero)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    @objc private func didTapOnActionButton() {
        delegate?.didTapOnActionButton(action: action)
    }
}

extension ActionView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [actionButton])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
