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
    private var subTitle: String?
    private var showHorizontally: Bool
    private var layout: PXOneTapHeaderMerchantLayout
    private var imageView: PXUIImageView?
    internal let IMAGE_NAV_SIZE: CGFloat = 40
    internal var IMAGE_SIZE: CGFloat {
        if UIDevice.isSmallDevice() {
            return IMAGE_NAV_SIZE
        } else if UIDevice.isLargeDevice() || UIDevice.isExtraLargeDevice() {
            return 65
        } else {
            return 55
        }
    }

    init(image: UIImage, title: String, subTitle: String? = nil, showHorizontally: Bool) {
        self.image = image
        self.title = title
        self.showHorizontally = showHorizontally
        self.subTitle = subTitle
        self.layout = PXOneTapHeaderMerchantLayout(layoutType: subTitle == nil ? .onlyTitle : .titleSubtitle)
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func render() {
        let containerView = UIView()
        let imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.dropShadow(radius: 2, opacity: 0.15)

        PXLayout.setHeight(owner: self, height: IMAGE_SIZE, relation: .greaterThanOrEqual).isActive = true

        let imageView = PXUIImageView()
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = IMAGE_SIZE / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.enableFadeIn()
        imageView.backgroundColor = .white
        imageView.image = image
        imageContainerView.addSubview(imageView)
        PXLayout.pinBottom(view: imageView).isActive = true
        PXLayout.pinLeft(view: imageView).isActive = true
        PXLayout.pinRight(view: imageView).isActive = true
        PXLayout.pinTop(view: imageView).isActive = true
        self.imageView = imageView
        containerView.addSubview(imageContainerView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = Utils.getSemiBoldFont(size: PXLayout.M_FONT)
        titleLabel.textColor = ThemeManager.shared.statusBarStyle() == UIStatusBarStyle.default ? UIColor.black : ThemeManager.shared.whiteColor()
        titleLabel.textAlignment = .center
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        containerView.addSubview(titleLabel)

        addSubviewToBottom(containerView)

        if layout.getLayoutType() == .onlyTitle {
            layout.makeConstraints(containerView, imageContainerView, titleLabel)
        } else {
            let subTitleLabel = UILabel()
            subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subTitleLabel.text = subTitle
            subTitleLabel.numberOfLines = 1
            subTitleLabel.lineBreakMode = .byTruncatingTail
            subTitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
            subTitleLabel.font = Utils.getFont(size: PXLayout.XXXS_FONT)
            subTitleLabel.textColor = ThemeManager.shared.statusBarStyle() == UIStatusBarStyle.default ? UIColor.black : ThemeManager.shared.whiteColor()
            subTitleLabel.textAlignment = .center
            containerView.addSubview(subTitleLabel)
            layout.makeConstraints(containerView, imageContainerView, titleLabel, subTitleLabel)
        }

        if showHorizontally {
            animateToHorizontal()
        } else {
            animateToVertical()
        }

        isUserInteractionEnabled = true
    }
}

// MARK: Publics
extension PXOneTapHeaderMerchantView {
    func updateContentViewLayout(margin: CGFloat = PXLayout.M_MARGIN) {
        self.layoutIfNeeded()
        if UIDevice.isLargeDevice() || UIDevice.isExtraLargeDevice() {
            self.pinContentViewToTop(margin: margin)
        } else if !UIDevice.isSmallDevice() {
            self.pinContentViewToTop()
        }
    }

    func animateToVertical(duration: Double = 0) {
        self.layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.layoutIfNeeded()

            for constraint in strongSelf.layout.getHorizontalContrainsts() {
                constraint.isActive = false
            }

            for constraint in strongSelf.layout.getVerticalContrainsts() {
                constraint.isActive = true
            }
            strongSelf.imageView?.layer.cornerRadius = strongSelf.layout.IMAGE_SIZE / 2
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    func animateToHorizontal(duration: Double = 0) {
        self.layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.layoutIfNeeded()
            strongSelf.pinContentViewToTop()
            for constraint in strongSelf.layout.getHorizontalContrainsts() {
                constraint.isActive = true
            }

            for constraint in strongSelf.layout.getVerticalContrainsts() {
                constraint.isActive = false
            }
            strongSelf.imageView?.layer.cornerRadius = strongSelf.layout.IMAGE_NAV_SIZE / 2
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }
}
