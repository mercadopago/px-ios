//
//  PXRemedyView.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 21/04/2020.
//

import UIKit
import MLCardDrawer

protocol PXRemedyViewProtocol: class {
    func remedyViewButtonTouchUpInside(_ sender: PXAnimatedButton)
}

struct PXRemedyViewData {
    let oneTapDto: PXOneTapDto?
    let remedy: PXRemedy

    weak var animatedButtonDelegate: PXAnimatedButtonDelegate?
    weak var remedyViewProtocol: PXRemedyViewProtocol?
    let remedyButtonTapped: ((String?) -> Void)?
}

class PXRemedyView: UIView {
    private let data: PXRemedyViewData

    init(data: PXRemedyViewData) {
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
        let titleLabel = buildTitleLabel(text: getRemedyMessage())
        addSubview(titleLabel)
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        let height = UILabel.requiredHeight(forText: getRemedyMessage(), withFont: titleLabel.font, inWidth: screenWidth)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: PXLayout.L_MARGIN),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: CONTENT_WIDTH_PERCENT  / 100),
            titleLabel.heightAnchor.constraint(equalToConstant: height),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        //CardDrawer
        if let cardDrawerView = buildCardDrawerView() {
            addSubview(cardDrawerView)
            NSLayoutConstraint.activate([
                cardDrawerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PXLayout.M_MARGIN),
                cardDrawerView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
                cardDrawerView.heightAnchor.constraint(equalToConstant: CARD_VIEW_HEIGHT),
                cardDrawerView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }

        if shouldShowTextField() {
            //TextField
            let textField = buildTextField(placeholder: getRemedyPlaceholder())
            self.textField = textField
            let lastView = subviews.last ?? titleLabel
            addSubview(textField)
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: PXLayout.M_MARGIN),
                textField.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
                textField.heightAnchor.constraint(equalToConstant: TEXTFIELD_HEIGHT),
                textField.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])

            //Hint Label
            if let hint = getRemedyHintMessage() {
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
        }

        if shouldShowButton(), let lastView = subviews.last ?? textField {
            //Button
            let button = buildPayButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
            self.button = button
            addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(greaterThanOrEqualTo: lastView.bottomAnchor, constant: PXLayout.M_MARGIN),
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PXLayout.S_MARGIN),
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PXLayout.S_MARGIN),
                button.heightAnchor.constraint(equalToConstant: BUTTON_HEIGHT),
                button.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        self.layoutIfNeeded()
    }

    private func buildTitleLabel(text: String) -> UILabel {
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

    private func buildTextField(placeholder: String) -> HoshiTextField {
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

    private func buildCardDrawerView() -> UIView? {
        guard data.remedy.cvv != nil || data.remedy.suggestedPaymentMethod != nil,
            let oneTapDto = data.oneTapDto else {
                return nil
        }

        var cardData: CardData
        var cardUI: CardUI
        if oneTapDto.accountMoney != nil {
            cardData = PXCardDataFactory()
            cardUI = AccountMoneyCard()
        } else if let oneTapCardUI = oneTapDto.oneTapCard?.cardUI,
            let cardName = oneTapCardUI.name,
            let cardNumber = oneTapCardUI.lastFourDigits,
            let cardExpiration = oneTapCardUI.expiration {
            cardData = PXCardDataFactory().create(cardName: cardName.uppercased(), cardNumber: cardNumber, cardCode: "", cardExpiration: cardExpiration, cardPattern: oneTapCardUI.cardPattern)

            let templateCard = TemplateCard()
            if let cardPattern = oneTapCardUI.cardPattern {
                templateCard.cardPattern = cardPattern
            }

            templateCard.securityCodeLocation = oneTapCardUI.securityCode?.cardLocation == "front" ? .front : .back

            if let cardBackgroundColor = oneTapCardUI.color {
                templateCard.cardBackgroundColor = cardBackgroundColor.hexToUIColor()
            }

            if let cardFontColor = oneTapCardUI.fontColor {
                templateCard.cardFontColor = cardFontColor.hexToUIColor()
            }

            if let cardLogoImageUrl = oneTapCardUI.paymentMethodImageUrl {
                templateCard.cardLogoImageUrl = cardLogoImageUrl
            }

            if let issuerImageUrl = oneTapCardUI.issuerImageUrl {
                templateCard.bankImageUrl = issuerImageUrl
            }
            cardUI = templateCard
        } else {
            return nil
        }

        let controller = MLCardDrawerController(cardUI, cardData, false, .medium)
        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)
        controller.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: CARD_VIEW_HEIGHT))
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.animated(false)
        controller.show()

        if oneTapDto.accountMoney != nil {
            let view = controller.getCardView()
            AccountMoneyCard.render(containerView: view, isDisabled: false, size: view.bounds.size)
        }

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
        button.backgroundColor = ThemeManager.shared.getAccentColor()
        button.setTitle(normalText, for: .normal)
        button.layer.cornerRadius = 4
        button.add(for: .touchUpInside, { [weak self] in
            if let remedyButtonTapped = self?.data.remedyButtonTapped {
                remedyButtonTapped(self?.textField?.text)
            }
            if let button = self?.button {
                self?.data.remedyViewProtocol?.remedyViewButtonTouchUpInside(button)
            }
        })
        if shouldShowTextField() {
            button.setDisabled()
        }
        return button
    }
}

extension PXRemedyView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isNumber {
            return false
        }
        if let text = textField.text as NSString? {
            let newString = text.replacingCharacters(in: range, with: string)
            if newString.count > getRemedyMaxLength() {
                return false
            }
            if newString.count == getRemedyMaxLength() {
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

extension PXRemedyView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}

// PXRemedy Helpers
extension PXRemedyView {
    private func getRemedyMessage() -> String {
        let remedy = data.remedy
        if let cvv = remedy.cvv, let text = cvv.message {
            return text
        } else if let highRisk = remedy.highRisk, let text = highRisk.message {
            return text
        } else if let suggestionPaymentMethod = remedy.suggestedPaymentMethod, let text = suggestionPaymentMethod.message {
            return text
        }
        return ""
    }

    private func getRemedyPlaceholder() -> String {
        let remedy = data.remedy
        if let cvv = remedy.cvv, let text = cvv.fieldSetting?.title {
            return text
//        } else if let suggestionPaymentMethod = remedy.suggestedPaymentMethod, let text = suggestionPaymentMethod.fieldSetting?.title {
//            return text
        }
        return ""
    }

    private func getRemedyHintMessage() -> String? {
        let remedy = data.remedy
        if let cvv = remedy.cvv, let text = cvv.fieldSetting?.hintMessage {
            return text
//        } else if let suggestionPaymentMethod = remedy.suggestedPaymentMethod, let text = suggestionPaymentMethod.fieldSetting?.hintMessage {
//            return text
        }
        return nil
    }

    private func getRemedyMaxLength() -> Int {
        let remedy = data.remedy
        if let cvv = remedy.cvv, let length = cvv.fieldSetting?.length {
            return length
        }
        return 0
    }

    private func shouldShowTextField() -> Bool {
        let remedy = data.remedy
        if remedy.cvv != nil && data.remedyViewProtocol != nil {
            return true
        }
        return false
    }

    private func shouldShowButton() -> Bool {
        let remedy = data.remedy
        if (remedy.cvv != nil || remedy.suggestedPaymentMethod != nil) &&
            data.animatedButtonDelegate != nil &&
            data.remedyButtonTapped != nil {
            return true
        }
        return false
    }
}
