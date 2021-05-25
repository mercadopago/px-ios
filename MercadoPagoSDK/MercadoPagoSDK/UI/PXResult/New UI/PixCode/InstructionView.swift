//
//  PixCodeView.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 22/04/21.
//

import UIKit

final class InstructionView: UIView {
    // MARK: - Private properties
    private weak var delegate: ActionViewDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_semiboldSystemFont(ofSize: 20)
        return label
    }()
    
    private let stepsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        return stack
    }()
    
    private let watchIcon: UIImageView = {
        let image = UIImageView()
        image.image = ResourceManager.shared.getImage("iconTime")
        return image
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialization
    init(instruction: PXInstruction, delegate: ActionViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupViewConfiguration()
        setupInfos(with: instruction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupInfos(with instruction: PXInstruction) {
        titleLabel.isHidden = instruction.subtitle == "" || instruction.subtitle == nil
        titleLabel.attributedText = instruction.subtitle?.htmlToAttributedString?.with(font: titleLabel.font)
        
        instruction.info.forEach { info in
            addLabel(info: info)
        }
        
        instruction.interactions?.forEach { interaction in
            addVariableComponents(interaction: interaction)
        }
        
        instruction.references?.forEach { reference in
            stepsStack.addArrangedSubviews(views: [InstructionReferenceView(reference: reference)])
        }
        
        instruction.actions?.forEach { action in
            stepsStack.addArrangedSubviews(views: [ActionView(action: action, delegate: self)])
        }
        
        instruction.secondaryInfo?.forEach { info in
            addLabel(info: info)
        }
        
        instruction.tertiaryInfo?.forEach { info in
            addLabel(info: info)
        }
        
        instruction.accreditationComments.forEach { info in
            addLabel(info: info)
        }
        
        footerLabel.attributedText = instruction.accreditationMessage?.htmlToAttributedString?.with(font: footerLabel.font)
    }
    
    private func addVariableComponents(interaction: PXInstructionInteraction) {
        if let _ = interaction.title, let _ = interaction.content, let _ = interaction.action {
            stepsStack.addArrangedSubviews(views: [InstructionActionView(instruction: interaction, delegate: self)])
        } else if let title = interaction.title {
            addLabel(info: title)
        }
    }
    
    private func addLabel(info: String) {
        let instructionLabel: UILabel = {
            let label = UILabel()
            label.attributedText = info.htmlToAttributedString?.with(font: UIFont.ml_lightSystemFont(ofSize: 16))
            label.numberOfLines = 0
            return label
        }()
        
        stepsStack.addArrangedSubviews(views: [instructionLabel])
    }
}

extension InstructionView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [titleLabel, stepsStack, watchIcon, footerLabel])
        stepsStack.addArrangedSubviews(views: [titleLabel])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stepsStack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stepsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stepsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            watchIcon.centerYAnchor.constraint(equalTo: footerLabel.centerYAnchor),
            watchIcon.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            watchIcon.heightAnchor.constraint(equalToConstant: 16),
            watchIcon.widthAnchor.constraint(equalToConstant: 16),
            
            footerLabel.topAnchor.constraint(equalTo: stepsStack.bottomAnchor, constant: 24),
            footerLabel.leadingAnchor.constraint(equalTo: watchIcon.trailingAnchor, constant: 8),
            footerLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func viewConfigure() {
        backgroundColor = .white
    }
}

extension InstructionView: ActionViewDelegate {
    func didTapOnActionButton(action: PXInstructionAction?) {
        delegate?.didTapOnActionButton(action: action)
    }
}
