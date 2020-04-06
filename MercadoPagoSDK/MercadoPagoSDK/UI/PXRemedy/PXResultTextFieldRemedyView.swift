//
//  PXResultTextFieldRemedyView.swift
//  Pods
//
//  Created by Eric Ertl on 12/03/2020.
//

import UIKit
import MLCardDrawer

protocol PXResultTextFieldRemedyViewDelegate: class {
    func remedyButtonTouchUpInside(_ sender: PXAnimatedButton)
}

struct PXResultTextFieldRemedyViewData {
    //let cardUI: CardUI?
    let title: String
    let placeholder: String
    let hint: String?
    let maxTextLength: Int

    let buttonColor: UIColor?
    weak var animatedButtonDelegate: PXAnimatedButtonDelegate?
    weak var resultTextFieldRemedyViewDelegate: PXResultTextFieldRemedyViewDelegate?
    let remedyButtonTapped: ((String?) -> Void)?
}

class PXResultTextFieldRemedyView: UIView {
    private let data: PXResultTextFieldRemedyViewData

    init(data: PXResultTextFieldRemedyViewData) {
        self.data = data
        super.init(frame: .zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let CONTENT_WIDTH_PERCENT: CGFloat = 84.0
    let TITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT
    let CARD_VIEW_WIDTH: CGFloat = 335
    let CARD_VIEW_HEIGHT: CGFloat = 109
    let TEXTFIELD_HEIGHT: CGFloat = 50.0
    let TEXTFIELD_FONT_SIZE: CGFloat = PXLayout.M_FONT
    let HINT_FONT_SIZE: CGFloat = PXLayout.XXS_FONT
    let BUTTON_HEIGHT: CGFloat = 50.0

    var textField: HoshiTextField?
    public var button: PXAnimatedButton?

    private func render() {
        removeAllSubviews()
        //Title Label
        let titleLabel = buildTitleLabel(with: data.title)
        addSubview(titleLabel)
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forText: data.title, withFont: titleLabel.font, inWidth: screenWidth)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: PXLayout.L_MARGIN),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CONTENT_WIDTH_PERCENT  / 100),
            titleLabel.heightAnchor.constraint(equalToConstant: height),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

//        //CardDrawer
//        let cardDrawerView = buildCardDrawerView()
//        addSubview(cardDrawerView)
//        NSLayoutConstraint.activate([
//            cardDrawerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PXLayout.M_MARGIN),
//            cardDrawerView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
//            cardDrawerView.heightAnchor.constraint(equalToConstant: CARD_VIEW_HEIGHT),
//            cardDrawerView.centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])

        //TextField
        let textField = buildTextField(with: data.placeholder)
        self.textField = textField
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PXLayout.M_MARGIN),
//            textField.topAnchor.constraint(equalTo: cardDrawerView.bottomAnchor, constant: PXLayout.M_MARGIN),
            textField.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: TEXTFIELD_HEIGHT),
            textField.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        //Hint Label
        if let hint = data.hint {
            let hintLabel = buildHintLabel(with: hint)
            addSubview(hintLabel)
            let height = UILabel.requiredHeight(forText: hint, withFont: hintLabel.font, inWidth: screenWidth)
            NSLayoutConstraint.activate([
                hintLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: PXLayout.XS_MARGIN),
                hintLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
                hintLabel.heightAnchor.constraint(equalToConstant: height),
                hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }

        //Button
        let button = buildPayButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        self.button = button
        let lastView = subviews.last ?? textField
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(greaterThanOrEqualTo: lastView.bottomAnchor, constant: PXLayout.M_MARGIN),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PXLayout.S_MARGIN),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PXLayout.S_MARGIN),
            button.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.layoutIfNeeded()
    }

    private func buildTitleLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.1725280285, green: 0.1725597382, blue: 0.1725237072, alpha: 1)
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont.ml_semiboldSystemFont(ofSize: TITLE_FONT_SIZE) ?? Utils.getSemiBoldFont(size: TITLE_FONT_SIZE)
        label.lineBreakMode = .byWordWrapping
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    private func buildTextField(with placeholder: String) -> HoshiTextField {
        let textField = HoshiTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderActiveColor = ThemeManager.shared.secondaryColor()
        textField.borderInactiveColor = ThemeManager.shared.secondaryColor()
        textField.font = Utils.getFont(size: TEXTFIELD_FONT_SIZE)
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.numberPad
        textField.keyboardAppearance = .light
        textField.delegate = self
        return textField
    }

    private func buildCardDrawerView() -> UIView {
        let cardName = "Milton Brandes".uppercased()
        let cardNumber = "1234"
        let cardExpiration = "11/12"
        let cardPattern = [4, 4, 4, 4]

        let cardData = PXCardDataFactory().create(cardName: cardName, cardNumber: cardNumber, cardCode: "", cardExpiration: cardExpiration, cardPattern: cardPattern)

        let templateCard = TemplateCard()
//        if let cardPattern = targetCardData.cardUI?.cardPattern {
            templateCard.cardPattern = cardPattern
//        }

//        if let cardBackgroundColor = targetCardData.cardUI?.color {
//            templateCard.cardBackgroundColor = cardBackgroundColor.hexToUIColor()
//        }
//
//        if let cardFontColor = targetCardData.cardUI?.fontColor {
//            templateCard.cardFontColor = cardFontColor.hexToUIColor()
//        }
//
//        if let paymentMethodId = targetNode.paymentMethodId, let paymentMethodImage = ResourceManager.shared.getPaymentMethodCardImage(paymentMethodId: paymentMethodId.lowercased()) {
//            templateCard.cardLogoImage = paymentMethodImage
//        }
//
//        if let issuerImageName = targetNode.oneTapCard?.cardUI?.issuerImage {
//            templateCard.bankImage = ResourceManager.shared.getIssuerCardImage(issuerImageName: issuerImageName)
//        }

        let controller = MLCardDrawerController(templateCard, cardData, false, .medium)
        controller.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CARD_VIEW_WIDTH, height: CARD_VIEW_HEIGHT))
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.animated(false)
        controller.show()

        return controller.view
    }

    private func buildHintLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1)
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont.ml_semiboldSystemFont(ofSize: HINT_FONT_SIZE) ?? Utils.getSemiBoldFont(size: HINT_FONT_SIZE)
        label.lineBreakMode = .byWordWrapping
        return label
    }

    private func buildPayButton(normalText: String, loadingText: String, retryText: String) -> PXAnimatedButton {
        let button = PXAnimatedButton(normalText: normalText, loadingText: loadingText, retryText: retryText)
        button.animationDelegate = data.animatedButtonDelegate
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = data.buttonColor
        button.setTitle(normalText, for: .normal)
        button.layer.cornerRadius = 4
        button.add(for: .touchUpInside, { [weak self] in
            if let remedyButtonTapped = self?.data.remedyButtonTapped {
                remedyButtonTapped(self?.textField?.text)
            }
            if let button = self?.button {
                self?.data.resultTextFieldRemedyViewDelegate?.remedyButtonTouchUpInside(button)
            }
        })
        button.setDisabled()
        return button
    }
}

extension PXResultTextFieldRemedyView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isNumber {
            return false
        }
        if let text = textField.text as NSString? {
            let newString = text.replacingCharacters(in: range, with: string)
            if newString.count > data.maxTextLength {
                return false
            }
            if newString.count == data.maxTextLength {
                button?.setEnabled()
            } else {
                button?.setDisabled()
            }
            let num = Int(newString)
            return (num != nil)
        }
        return true
    }
}

extension PXResultTextFieldRemedyView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
