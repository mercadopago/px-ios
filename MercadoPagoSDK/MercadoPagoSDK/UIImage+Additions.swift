//
//  UIImage+Additions.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 1/17/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

internal extension UIImage {
    func imageGreyScale() -> UIImage {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let greyContext = CGContext(
            data: nil, width: Int(self.size.width*self.scale), height: Int(self.size.height*self.scale),
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo.init(rawValue: CGImageAlphaInfo.none.rawValue).rawValue

        )
        let alphaContext = CGContext(data: nil, width: Int(self.size.width*self.scale), height: Int(self.size.height*self.scale), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
        )

        greyContext!.scaleBy(x: self.scale, y: self.scale)
        alphaContext!.scaleBy(x: self.scale, y: self.scale)

        greyContext?.draw(self.cgImage!, in: imageRect)
        alphaContext?.draw(self.cgImage!, in: imageRect)

        let greyImage = greyContext!.makeImage()
        let maskImage = alphaContext!.makeImage()
        let combinedImage = greyImage!.masking(maskImage!)
        return UIImage(cgImage: combinedImage!)
    }

    func imageWithOverlayTint(tintColor: UIColor) -> UIImage {
        if tintColor == UIColor.px_blueMercadoPago() {
            return self
        } else {
            UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
            let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            self.draw(in: bounds)
            tintColor.setFill()
            UIRectFillUsingBlendMode(bounds, CGBlendMode.darken)

            self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tintedImage!
        }
    }
}
