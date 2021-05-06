//
//  PixCodeView.swift
//  AndesUI
//
//  Created by Matheus Leandro Martins on 22/04/21.
//

import UIKit

final class PixCodeView: UIView {
    // MARK: - Private properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_semiboldSystemFont(ofSize: 20)
        return label
    }()
    
    private let firstStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_semiboldSystemFont(ofSize: 16)
        label.textColor = UIColor.black.withAlphaComponent(0.45)
        label.textAlignment = .center
        label.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 6
        label.numberOfLines = 2
        return label
    }()
    
    private let copyCodeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.ml_semiboldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor(red: 52, green: 131, blue: 250), for: .normal)
        return button
    }()
    
    private let stepsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let secondStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let thirdStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let fourthStepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
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
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return view
    }()
    
    // MARK: - Initialization
    init(pixModel: PixCodeModel) {
        super.init(frame: .zero)
        setupViewConfiguration()
        setupInfos(with: pixModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupInfos(with pixModel: PixCodeModel) {
        titleLabel.text = pixModel.title
        firstStepLabel.attributedText = pixModel.firstStep.htmlToAttributedString?.with(font: UIFont.ml_regularSystemFont(ofSize: 16))
        codeLabel.text = pixModel.code
        copyCodeButton.setTitle(pixModel.buttonText, for: .normal)
        secondStepLabel.attributedText = pixModel.secondStep.htmlToAttributedString?.with(font: UIFont.ml_regularSystemFont(ofSize: 16))
        thirdStepLabel.attributedText = pixModel.thirdStep.htmlToAttributedString?.with(font: UIFont.ml_regularSystemFont(ofSize: 16))
        fourthStepLabel.attributedText = pixModel.fourthStep.htmlToAttributedString?.with(font: UIFont.ml_regularSystemFont(ofSize: 16))
        footerLabel.text = pixModel.footerText
    }
}

extension PixCodeView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [titleLabel, firstStepLabel, codeLabel, copyCodeButton, stepsStack, watchIcon, footerLabel, separatorView])
        stepsStack.addArrangedSubviews(views: [secondStepLabel, thirdStepLabel, fourthStepLabel])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            firstStepLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            firstStepLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            firstStepLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            codeLabel.topAnchor.constraint(equalTo: firstStepLabel.bottomAnchor, constant: 8),
            codeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            codeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            codeLabel.heightAnchor.constraint(equalToConstant: 52),
            
            copyCodeButton.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 6),
            copyCodeButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            copyCodeButton.heightAnchor.constraint(equalToConstant: 18),
            
            stepsStack.topAnchor.constraint(equalTo: copyCodeButton.bottomAnchor, constant: 18),
            stepsStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stepsStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            watchIcon.centerYAnchor.constraint(equalTo: footerLabel.centerYAnchor),
            watchIcon.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            watchIcon.heightAnchor.constraint(equalToConstant: 16),
            watchIcon.widthAnchor.constraint(equalToConstant: 16),
            
            footerLabel.topAnchor.constraint(equalTo: stepsStack.bottomAnchor, constant: 24),
            footerLabel.leadingAnchor.constraint(equalTo: watchIcon.trailingAnchor, constant: 8),
            footerLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: footerLabel.bottomAnchor, constant: 24),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func viewConfigure() {
        backgroundColor = .white
    }
}
