//
//  InstructionActionView.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 10/05/21.
//

import UIKit

final class InstructionActionView: UIView {
    // MARK: - Private properties
    private weak var delegate: ActionViewDelegate?
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let codeBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_semiboldSystemFont(ofSize: 16)
        label.textColor = UIColor.black.withAlphaComponent(0.45)
        label.textAlignment = .left
        return label
    }()
    
    private let actionButton: ActionView
    
    // MARK: - Initialization
    init(instruction: PXInstructionInteraction, delegate: ActionViewDelegate?) {
        self.actionButton = ActionView(action: instruction.action, delegate: delegate)
        self.delegate = delegate
        super.init(frame: .zero)
        setupInfos(with: instruction)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupInfos(with instruction: PXInstructionInteraction) {
        instructionLabel.attributedText = instruction.title?.htmlToAttributedString?.with(font: instructionLabel.font)
        codeBorderView.isHidden = instruction.content == nil || instruction.content == ""
        codeLabel.numberOfLines = instruction.isBoleto ? 0 : 1
        codeLabel.text = instruction.content
    }
}

extension InstructionActionView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [mainStack])
        codeBorderView.addSubviews(views: [codeLabel])
        mainStack.addArrangedSubviews(views: [instructionLabel, codeBorderView, actionButton])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            codeBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            codeBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),

            codeLabel.topAnchor.constraint(equalTo: codeBorderView.topAnchor, constant: 8),
            codeLabel.leadingAnchor.constraint(equalTo: codeBorderView.leadingAnchor, constant: 16),
            codeLabel.trailingAnchor.constraint(equalTo: codeBorderView.trailingAnchor, constant: -16),
            codeLabel.bottomAnchor.constraint(equalTo: codeBorderView.bottomAnchor, constant: -8),
        ])
    }
    
    func viewConfigure() {
        backgroundColor = .white
    }
}
