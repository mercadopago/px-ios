//
//  AccountMoneyCard.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 17/10/18.
//

import Foundation
import MLCardDrawer

class AccountMoneyCard: NSObject, CustomCardDrawerUI {
    var placeholderName = ""
    var placeholderExpiration = ""
    var bankImage: UIImage?
    var cardPattern = [0]
    var cardFontColor: UIColor = UIColor(red: 105 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = UIColor(red: 0.00, green: 0.64, blue: 0.85, alpha: 1.0)
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = false
    var securityCodePattern = 3
    var fontType: String = "light"
}

extension AccountMoneyCard {
    static func render(containerView: UIView, balanceText: String, isDisabled: Bool) {
        let amImage = UIImageView()
        amImage.backgroundColor = .clear
        amImage.contentMode = .scaleAspectFit
        let amImageRaw = ResourceManager.shared.getImage("amImage")
        amImage.image = isDisabled ? amImageRaw?.imageGreyScale() : amImageRaw
        amImage.alpha = 0.6
        containerView.addSubview(amImage)
        PXLayout.setWidth(owner: amImage, width: PXCardSliderSizeManager.getItemContainerSize().height * 0.65).isActive = true
        PXLayout.setHeight(owner: amImage, height: PXCardSliderSizeManager.getItemContainerSize().height * 0.65).isActive = true
        PXLayout.pinTop(view: amImage).isActive = true
        PXLayout.pinRight(view: amImage).isActive = true

        let patternView = UIImageView()
        patternView.contentMode = .scaleAspectFit
        patternView.image = ResourceManager.shared.getImage("amPattern")
        let patternDeltaOffset: CGFloat = 5
        containerView.addSubview(patternView)

        let height = PXCardSliderSizeManager.getItemContainerSize().height
        let width = height * 1.1

        PXLayout.setHeight(owner: patternView, height: height).isActive = true
        PXLayout.setWidth(owner: patternView, width: width).isActive = true
        PXLayout.pinTop(view: patternView).isActive = true
        PXLayout.pinRight(view: patternView, withMargin: patternDeltaOffset).isActive = true

        let label = UILabel()
        label.text = " \(balanceText)   "
        label.font = Utils.getFont(size: PXLayout.XXS_FONT)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        containerView.addSubview(label)
        PXLayout.pinLeft(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinBottom(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.setHeight(owner: label, height: PXLayout.L_MARGIN).isActive = true

        let amLogo = UIImageView()
        amLogo.backgroundColor = .clear
        amLogo.contentMode = .scaleAspectFit
        let logoImage = ResourceManager.shared.getImage("amLogo")
        amLogo.image = isDisabled ? logoImage?.imageGreyScale() : logoImage
        containerView.addSubview(amLogo)
        PXLayout.setWidth(owner: amLogo, width: PXCardSliderSizeManager.getItemContainerSize().height * 0.60).isActive = true
        PXLayout.setHeight(owner: amLogo, height: PXCardSliderSizeManager.getItemContainerSize().height * 0.35).isActive = true
        PXLayout.pinTop(view: amLogo, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.pinLeft(view: amLogo, to: label, withMargin: 0).isActive = true
    }
}
