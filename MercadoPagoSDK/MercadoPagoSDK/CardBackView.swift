//
//  CardBackView.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/20/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
@IBDesignable open class CardBackView: UIView {
    var view: UIView!

    @IBOutlet weak var cardCVV: PXMonospaceLabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CardBackView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
       // let screenSize: CGRect = UIScreen.mainScreen().bounds
       // let screenHeight = screenSize.height
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)

        //let circlePath = UIBezierPath(arcCenter:cardCVV.center, radius: CGFloat(screenHeight*0.05), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)

       // let shapeLayer = CAShapeLayer()
       // shapeLayer.path = circlePath.CGPath

        //change the fill color
       // shapeLayer.fillColor = UIColor.clearColor().CGColor
        //you can change the stroke color
       // shapeLayer.strokeColor = UIColor.redColor().CGColor
        //you can change the line width
       // shapeLayer.lineWidth = 4.0

      //  cardCVV.layer.addSublayer(shapeLayer)
        cardCVV.numberOfLines = 0
        cardCVV.font = UIFont.systemFont(ofSize: cardCVV.font.pointSize)

    }

}
