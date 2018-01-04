//
//  File.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/11/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

extension UIView {

    //Eventualmente hay que borrar esto. Cuando summary deje de usarlo
    func addSeparatorLineToTop(horizontalMargin: CGFloat, width: CGFloat, height: CGFloat) {
        let lineFrame = CGRect(origin: CGPoint(x: horizontalMargin, y :0), size: CGSize(width: width, height: height))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.pxMediumLightGray
        addSubview(line)
    }

    func addSeparatorLineToTop(height: CGFloat, horizontalMarginPercentage: CGFloat = 100, color: UIColor = .pxMediumLightGray) {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        self.addSubview(line)
        PXLayout.pinTop(view: line).isActive = true
        PXLayout.matchWidth(ofView: line, withPercentage: horizontalMarginPercentage).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: height).isActive = true
    }

    //Eventualmente hay que borrar esto. Cuando summary deje de usarlo
    func addSeparatorLineToBottom(horizontalMargin: CGFloat, width: CGFloat, height: CGFloat) {
        let lineFrame = CGRect(origin: CGPoint(x: horizontalMargin, y :self.frame.size.height - height), size: CGSize(width: width, height: height))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.pxMediumLightGray
        addSubview(line)
    }

    func addSeparatorLineToBottom(height: CGFloat, horizontalMarginPercentage: CGFloat = 100, color: UIColor = .pxMediumLightGray) {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        self.addSubview(line)
        PXLayout.pinBottom(view: line).isActive = true
        PXLayout.matchWidth(ofView: line, withPercentage: horizontalMarginPercentage).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: height).isActive = true
    }

    //Eventualmente hay que borrar esto. Cuando summary deje de usarlo
    func addLine(y: CGFloat, horizontalMargin: CGFloat, width: CGFloat, height: CGFloat) {
        let lineFrame = CGRect(origin: CGPoint(x: horizontalMargin, y :y), size: CGSize(width: width, height: height))
        let line = UIView(frame: lineFrame)
        line.alpha = 0.6
        line.backgroundColor = UIColor.px_grayLight()
        addSubview(line)
    }

    func addLine(yCoordinate: CGFloat, height: CGFloat, horizontalMarginPercentage: CGFloat = 100, color: UIColor = .pxMediumLightGray) {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = color
        self.addSubview(line)
        PXLayout.pinBottom(view: line, withMargin: yCoordinate).isActive = true
        PXLayout.matchWidth(ofView: line, withPercentage: horizontalMarginPercentage).isActive = true
        PXLayout.centerHorizontally(view: line).isActive = true
        PXLayout.setHeight(owner: line, height: height).isActive = true
    }
}
