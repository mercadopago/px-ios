//
//  PXUIImageView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXUIImageView: UIImageView {

    private var currentImage : UIImage?
    override var image: UIImage? {
        set {
            loadImage(image: newValue)
        }
        get {
            return currentImage
        }
    }

    private func loadImage(image: UIImage?) {
        self.contentMode = .scaleAspectFit
        if let pxImage = image as? PXUIImage {
            Utils().loadImageFromURLWithCache(withUrl: pxImage.url, targetView: self, placeholderView: buildLabel(with: pxImage.placeholder), fallbackView: buildLabel(with: pxImage.fallback)){ newImage in
                self.currentImage = newImage
            }
        } else {
            self.currentImage = image
        }
    }

    private func buildLabel(with text: String?) -> UILabel? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Utils.getFont(size: PXLayout.XS_FONT)
        label.textColor = ThemeManager.shared.labelTintColor()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.text = text
        return label
    }
}
