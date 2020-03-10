//
//  PXTextFieldRemedyRenderer.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 05/03/2020.
//

import Foundation

class PXTextFieldRemedyRenderer: NSObject {

    let CONTENT_WIDTH_PERCENT: CGFloat = 84.0
    let TITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT
    let HINT_FONT_SIZE: CGFloat = PXLayout.XXS_FONT

    func render(component: PXTextFieldRemedyComponent) -> PXTextFieldRemedyView {
        let errorBodyView = PXTextFieldRemedyView()
        errorBodyView.backgroundColor = .white
        errorBodyView.translatesAutoresizingMaskIntoConstraints = false

        //Title Label
        if let title = component.props.title, title.string.isNotEmpty {
            errorBodyView.titleLabel = buildTitleLabel(with: title, in: errorBodyView)
        }

        //Input View
        errorBodyView.inputTextField = buildInputTextField(delegate: errorBodyView, in: errorBodyView, onBottomOf: errorBodyView.titleLabel)

        //Hint Label
        if let hint = component.props.hint, hint.string.isNotEmpty {
            errorBodyView.hintLabel = buildHintLabel(with: hint, in: errorBodyView, onBottomOf: errorBodyView.inputTextField)
        }

        errorBodyView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true
        return errorBodyView
    }

    func buildTitleLabel(with text: NSAttributedString, in superView: UIView) -> UILabel {
        let label = UILabel()
        let font = UIFont.ml_semiboldSystemFont(ofSize: TITLE_FONT_SIZE) ?? Utils.getSemiBoldFont(size: TITLE_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.1725280285, green: 0.1725597382, blue: 0.1725237072, alpha: 1)
        label.numberOfLines = 0
        label.attributedText = text
        label.font = font
        label.lineBreakMode = .byWordWrapping
        superView.addSubview(label)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forAttributedText: text, withFont: font, inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        PXLayout.matchWidth(ofView: label, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: label, to: superView).isActive = true
        PXLayout.pinTop(view: label, withMargin: PXLayout.L_MARGIN).isActive = true
        return label
    }

    func buildInputTextField(delegate: UITextFieldDelegate, in superView: UIView, onBottomOf upperView: UIView?) -> HoshiTextField {
        let textField = HoshiTextField()

        textField.placeholder = "security_code".localized
        textField.borderActiveColor = ThemeManager.shared.secondaryColor()
        textField.borderInactiveColor = ThemeManager.shared.secondaryColor()
        textField.font = Utils.getFont(size: 20.0)
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.numberPad
        textField.keyboardAppearance = .light
        textField.delegate = delegate

        superView.addSubview(textField)

        PXLayout.setHeight(owner: textField, height: 50).isActive = true
        PXLayout.matchWidth(ofView: textField, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: textField, to: superView).isActive = true

        if let upperView = upperView {
            PXLayout.put(view: textField, onBottomOf: upperView, withMargin: PXLayout.M_MARGIN).isActive = true
        }
        return textField
    }

    func buildHintLabel(with text: NSAttributedString, in superView: UIView, onBottomOf upperView: UIView?) -> UILabel {
        let label = UILabel()
        let font = UIFont.ml_semiboldSystemFont(ofSize: HINT_FONT_SIZE) ?? Utils.getSemiBoldFont(size: HINT_FONT_SIZE)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1)
        label.numberOfLines = 0
        label.attributedText = text
        label.font = font
        label.lineBreakMode = .byWordWrapping
        superView.addSubview(label)

        let screenWidth = PXLayout.getScreenWidth(applyingMarginFactor: CONTENT_WIDTH_PERCENT)

        let height = UILabel.requiredHeight(forAttributedText: text, withFont: font, inWidth: screenWidth)
        PXLayout.setHeight(owner: label, height: height).isActive = true
        PXLayout.matchWidth(ofView: label, toView: superView, withPercentage: CONTENT_WIDTH_PERCENT).isActive = true
        PXLayout.centerHorizontally(view: label, to: superView).isActive = true
        if let upperView = upperView {
            PXLayout.put(view: label, onBottomOf: upperView, withMargin: PXLayout.M_MARGIN).isActive = true
        }
        return label
    }
}

class PXTextFieldRemedyView: PXComponentView {
    var titleLabel: UILabel?
    var inputTextField: HoshiTextField?
    var hintLabel: UILabel?
}

extension PXTextFieldRemedyView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
}

extension PXTextFieldRemedyView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
