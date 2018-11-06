//
//  PXOneTapHeaderMerchantView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/10/18.
//

import UIKit

class PXOneTapHeaderMerchantView: PXComponentView {
    let image: UIImage
    let title: String
    let showHorizontally: Bool

    init(image: UIImage, title: String, showHorizontally: Bool) {
        self.image = image
        self.title = title
        self.showHorizontally = showHorizontally
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var IMAGE_SIZE: CGFloat {
        if UIDevice.isSmallDevice() {
            return 40
        } else if UIDevice.isLargeDevice() || UIDevice.isExtraLargeDevice() {
            return 65
        } else {
            return 55
        }
    }

    private func render() {
        let containerView = UIView()

        let imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.dropShadow(radius: 2, opacity: 0.15)

        let imageView = PXUIImageView()
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = IMAGE_SIZE/2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.enableFadeIn()
        imageView.backgroundColor = .white
        imageView.image = image
        imageContainerView.addSubview(imageView)

        PXLayout.pinTop(view: imageView).isActive = true
        PXLayout.pinBottom(view: imageView).isActive = true
        PXLayout.pinLeft(view: imageView).isActive = true
        PXLayout.pinRight(view: imageView).isActive = true

        containerView.addSubview(imageContainerView)
        PXLayout.setHeight(owner: imageContainerView, height: IMAGE_SIZE).isActive = true
        PXLayout.setWidth(owner: imageContainerView, width: IMAGE_SIZE).isActive = true

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = Utils.getSemiBoldFont(size: PXLayout.M_FONT)
        titleLabel.textColor = ThemeManager.shared.statusBarStyle() == UIStatusBarStyle.default ? UIColor.black : ThemeManager.shared.whiteColor()
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)

        self.addSubviewToBottom(containerView)
        PXLayout.pinBottom(view: containerView).isActive = true
        PXLayout.centerHorizontally(view: containerView).isActive = true

        if showHorizontally {
            self.pinContentViewToTop()
            PXLayout.pinTop(view: imageContainerView, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinBottom(view: imageContainerView, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinLeft(view: imageContainerView, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinRight(view: titleLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.put(view: imageContainerView, leftOf: titleLabel, withMargin: PXLayout.XXS_MARGIN, relation: .equal).isActive = true
            PXLayout.centerVertically(view: imageContainerView, to: titleLabel).isActive = true
        } else {
            PXLayout.centerHorizontally(view: imageContainerView).isActive = true
            PXLayout.pinTop(view: imageContainerView, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.centerHorizontally(view: titleLabel).isActive = true
            PXLayout.put(view: titleLabel, onBottomOf: imageContainerView, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.pinBottom(view: titleLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true
            PXLayout.matchWidth(ofView: containerView).isActive = true
        }
    }
}
