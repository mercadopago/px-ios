//
//  HybridAMCard.swift
//  MercadoPagoSDK
//
//  Created by Jonathan Scaramal on 11/11/2020.
//

import Foundation
import MLCardDrawer

class HybridAMCard: NSObject, CustomCardDrawerUI {
    
    var placeholderName = ""
    var placeholderExpiration = ""
    var bankImage: UIImage?
    var cardPattern = [0]
    var cardFontColor: UIColor = UIColor(red: 105 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1)
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = false
    var securityCodePattern = 3
    var fontType: String = "light"
    var ownOverlayImage: UIImage? = UIImage()
    var ownGradient: CAGradientLayer
    var cardLogoImageUrl: String?
    
    init(isDisabled: Bool = false, cardLogoImageUrl: String?, color: String?, gradientColors: [String]?) {
        
        let disabledColor = UIColor(red: 204 / 255, green: 204 / 255, blue: 204 / 255, alpha: 1.0)
        
        var backgroundColor : UIColor?
        
        if let color = color {
            backgroundColor = UIColor.fromHex(color)
        } else {
            backgroundColor = UIColor(red: 16 / 255, green: 24 / 255, blue: 32 / 255, alpha: 1.0)
        }
        
        self.cardBackgroundColor = isDisabled ? disabledColor : backgroundColor!
        
        self.ownGradient = { () -> CAGradientLayer in
            let gradient = CAGradientLayer()
            
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.6, y: 0.5)
            
            if let gradientColors = gradientColors, gradientColors.count > 0 {
                // If gradient colors has been set on backend
                if gradientColors.count == 2 {
                    // If there is 2 colors
                    gradient.colors = [UIColor.fromHex(gradientColors[0]).cgColor, UIColor.fromHex(gradientColors[1]).cgColor]
                } else {
                    // If there is only one color
                    gradient.colors = [UIColor.fromHex(gradientColors[0]).cgColor, UIColor.fromHex(gradientColors[0]).cgColor]
                }
            } else {
                // If gradient colors hasn't been set
                gradient.colors = [backgroundColor!.cgColor, backgroundColor!.cgColor]
            }
            
            return gradient
        }()
        
        self.cardLogoImageUrl = cardLogoImageUrl
    }
    
}

extension HybridAMCard {
    func render(containerView: UIView, isDisabled: Bool, size: CGSize) {
        // Image
        let amImage = UIImageView()
        amImage.backgroundColor = .clear
        amImage.contentMode = .scaleAspectFit
        let amImageRaw = ResourceManager.shared.getImage("hybridAmImage")
        amImage.image = amImageRaw
        amImage.alpha = 1
        containerView.addSubview(amImage)
        PXLayout.setWidth(owner: amImage, width: size.height).isActive = true
        PXLayout.setHeight(owner: amImage, height: size.height).isActive = true
        PXLayout.pinTop(view: amImage).isActive = true
        PXLayout.pinRight(view: amImage).isActive = true

        // Logo
        guard let imageURL = self.cardLogoImageUrl, imageURL.isNotEmpty else {
            let image = ResourceManager.shared.getImage("hybridAmLogo")
            
            let amLogo = PXUIImageView(image: image, showAsCircle: false, showBorder: false, shouldAddInsets: true)
            
            amLogo.backgroundColor = .clear
            amLogo.contentMode = .scaleAspectFit
            
            containerView.addSubview(amLogo)
            
            PXLayout.setWidth(owner: amLogo, width: size.height * 0.15).isActive = true
            PXLayout.setHeight(owner: amLogo, height: size.height * 0.15).isActive = true
            PXLayout.pinTop(view: amLogo, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinLeft(view: amLogo, withMargin: PXLayout.M_MARGIN).isActive = true
            
            return
        }
    }
}
