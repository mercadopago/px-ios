//
//  File.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

extension UIView {
    func addSeparatorLineToTop(horizontalMargin: CGFloat, width: CGFloat, height: CGFloat) {
        let lineFrame = CGRect(origin: CGPoint(x: horizontalMargin, y :0), size: CGSize(width: width, height: height))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.px_grayLight()
        addSubview(line)
    }
    func addSeparatorLineToBottom(horizontalMargin: CGFloat, width: CGFloat, height: CGFloat) {
        let lineFrame = CGRect(origin: CGPoint(x: horizontalMargin, y :self.frame.size.height - height), size: CGSize(width: width, height: height))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.px_grayLight()
        addSubview(line)
    }
}
