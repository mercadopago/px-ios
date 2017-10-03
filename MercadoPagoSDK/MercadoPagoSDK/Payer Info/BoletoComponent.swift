//
//  BoletoComponent.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class BoletoComponent: UIView, PXComponent {
    static let IMAGE_WIDTH: CGFloat = 242.0
    static let IMAGE_HEIGHT: CGFloat = 143.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getHeight() -> CGFloat {
        return self.frame.size.height
    }
    func getWeight() -> CGFloat {
        return self.frame.size.width
    }

    func setupView() {
        var boletoImageView = UIImageView(frame: CGRect(x: getImageX(), y: getImageY(), width: BoletoComponent.IMAGE_WIDTH, height: BoletoComponent.IMAGE_HEIGHT))
        boletoImageView.image = MercadoPago.getImage("boleto")
        let xConstraint = NSLayoutConstraint(item: boletoImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: boletoImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraint(xConstraint)
        self.addConstraint(yConstraint)
      //  NSLayoutConstraint.activate([xConstraint, yConstraint])

        self.addSubview(boletoImageView)
    }
    
   
    
    func getImageX() -> CGFloat {
        return (self.getWeight() - BoletoComponent.IMAGE_WIDTH) / 2
    }
    func getImageY() -> CGFloat {
        return (self.getHeight() - BoletoComponent.IMAGE_HEIGHT) / 2
    }
}
