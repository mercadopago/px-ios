//
//  ConsumerCreditsCard.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 03/07/2019.
//

import Foundation
import MLCardDrawer

class ConsumerCreditsCard: NSObject, CustomCardDrawerUI {

    weak var delegate: PXTermsAndConditionViewDelegate?

    // CustomCardDrawerUI
    var placeholderName = ""
    var placeholderExpiration = ""
    var bankImage: UIImage?
    var cardPattern = [0]
    var cardFontColor: UIColor = .white
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = #colorLiteral(red: 0.0431372549, green: 0.7065708517, blue: 0.7140994326, alpha: 1)
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = false
    var securityCodePattern = 3
    var fontType: String = "light"
    var ownOverlayImage: UIImage? = ResourceManager.shared.getImage("creditsOverlayMask")
    var ownGradient: CAGradientLayer = CAGradientLayer()

    init(_ creditsViewModel: CreditsViewModel) {
        ownGradient = ConsumerCreditsCard.getCustomGradient(creditsViewModel)
    }
    static func getCustomGradient(_ creditsViewModel: CreditsViewModel) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = creditsViewModel.getCardColors()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.6, y: 0.5)
        return gradient
    }
}

// MARK: Render
extension ConsumerCreditsCard {
    func render(containerView: UIView, creditsViewModel: CreditsViewModel, isDisabled: Bool, size: CGSize) {
        let creditsImageHeight: CGFloat = size.height * 0.35
        let creditsImageWidth: CGFloat = size.height * 0.60
        let margins: CGFloat = 16
        let termsAndConditionsTextHeight: CGFloat = 48

        let consumerCreditsImage = getConsumerCreditsImageView(isDisabled: isDisabled)
        containerView.addSubview(consumerCreditsImage)
        NSLayoutConstraint.activate([
            PXLayout.setWidth(owner: consumerCreditsImage, width: creditsImageWidth),
            PXLayout.setHeight(owner: consumerCreditsImage, height: creditsImageHeight),
            PXLayout.centerHorizontally(view: consumerCreditsImage),
            PXLayout.centerVertically(view: consumerCreditsImage, to: containerView, withMargin: -creditsImageHeight/2)
        ])

        let titleLabel = getTitleLabel(creditsViewModel: creditsViewModel)
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            PXLayout.pinLeft(view: titleLabel, to: containerView, withMargin: margins),
            PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: margins),
            PXLayout.put(view: titleLabel, onBottomOf: consumerCreditsImage)
        ])

        let termsAndConditionsText = getTermsAndConditionsTextView()
        containerView.addSubview(termsAndConditionsText)
        NSLayoutConstraint.activate([
            PXLayout.pinBottom(view: termsAndConditionsText, to: containerView, withMargin: margins - PXLayout.XXXS_MARGIN),
            PXLayout.pinLeft(view: termsAndConditionsText, to: containerView, withMargin: margins),
            PXLayout.pinRight(view: termsAndConditionsText, to: containerView, withMargin: margins)
        ])

        PXLayout.setHeight(owner: termsAndConditionsText, height: termsAndConditionsTextHeight).isActive = true
        let tycText = creditsViewModel.displayInfo.bottomText.text
        let attributedString = NSMutableAttributedString(string: tycText)

        var phrases: [PXLinkablePhraseDto] = [PXLinkablePhraseDto]()
        if let remotePhrases = creditsViewModel.displayInfo.bottomText.linkablePhrases {
            phrases = remotePhrases
        }

        for linkablePhrase in phrases {
            if let customLink = linkablePhrase.link {
                let tycLinkRange = (tycText as NSString).range(of: linkablePhrase.phrase)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tycLinkRange)
                attributedString.addAttribute(NSAttributedString.Key.link, value: customLink, range: tycLinkRange)
            } else if let customHtml = linkablePhrase.html {
                let customLink = HtmlStorage.shared.set(customHtml)
                let tycLinkRange = (tycText as NSString).range(of: linkablePhrase.phrase)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tycLinkRange)
                attributedString.addAttribute(NSAttributedString.Key.link, value: customLink, range: tycLinkRange)
            }
        }

        termsAndConditionsText.attributedText = attributedString
        termsAndConditionsText.textAlignment = .center
        termsAndConditionsText.textColor = .white
    }
}

// MARK: UITextViewDelegate
extension ConsumerCreditsCard: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if let range = Range(characterRange, in: textView.text),
                let text = textView.text?[range] {
                let title = String(text).capitalized
                delegate?.shouldOpenTermsCondition(title, url: URL)
            }
        return false
    }
}

// MARK: Privates
extension ConsumerCreditsCard {

    private func getConsumerCreditsImageView(isDisabled: Bool) -> UIImageView {
        let consumerCreditsImage = UIImageView()
        consumerCreditsImage.backgroundColor = .clear
        consumerCreditsImage.contentMode = .scaleAspectFit
        let consumerCreditsImageRaw = ResourceManager.shared.getImage("consumerCreditsOneTap")
        consumerCreditsImage.image = isDisabled ? consumerCreditsImageRaw?.imageGreyScale() : consumerCreditsImageRaw
        return consumerCreditsImage
    }

    private func getTitleLabel(creditsViewModel: CreditsViewModel) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = creditsViewModel.displayInfo.topText.text
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = titleLabel.font.withSize(PXLayout.XXXS_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private func getTermsAndConditionsTextView() -> UITextView {
        let termsAndConditionsText = UITextView()
        termsAndConditionsText.linkTextAttributes = [.foregroundColor: UIColor.white]
        termsAndConditionsText.delegate = self
        termsAndConditionsText.isUserInteractionEnabled = true
        termsAndConditionsText.isEditable = false
        termsAndConditionsText.backgroundColor = .clear
        termsAndConditionsText.translatesAutoresizingMaskIntoConstraints = false
        return termsAndConditionsText
    }
}
