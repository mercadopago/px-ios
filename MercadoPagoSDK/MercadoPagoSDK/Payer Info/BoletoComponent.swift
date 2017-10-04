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
    var boletoView : UIView!
    
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
        var boletoImageView = UIImageView(frame: CGRect(x: 0, y:0, width: BoletoComponent.IMAGE_WIDTH, height: BoletoComponent.IMAGE_HEIGHT))
        boletoImageView.image = MercadoPago.getImage("boleto")
        self.boletoView = UIView(frame: CGRect(x: getImageX(), y: getImageY(), width: BoletoComponent.IMAGE_WIDTH, height: BoletoComponent.IMAGE_HEIGHT))
        self.boletoView.addSubview(boletoImageView)
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 15, width:BoletoComponent.IMAGE_WIDTH - 2 * 16 , height: 14))
        titleLabel.text = "DADOS PARA VALIDAR O SEU PAGAMENTO".localized
        titleLabel.font = Utils.getFont(size: 10.0)
        titleLabel.textColor = UIColor.px_grayDark()
        self.boletoView.addSubview(titleLabel)
        self.addSubview(self.boletoView)
        
    }
    
   
    public func updateView(){
        self.boletoView.frame = CGRect(x: getImageX(), y: getImageY(), width: BoletoComponent.IMAGE_WIDTH, height: BoletoComponent.IMAGE_HEIGHT)
    }
    func getImageX() -> CGFloat {
        return (self.getWeight() - BoletoComponent.IMAGE_WIDTH) / 2
    }
    func getImageY() -> CGFloat {
        return (self.getHeight() - BoletoComponent.IMAGE_HEIGHT) / 2
    }
}
