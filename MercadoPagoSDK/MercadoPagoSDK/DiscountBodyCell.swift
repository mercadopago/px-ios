//
//  DiscountBodyCell.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/5/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class DiscountBodyCell: UIView {

    let margin : CGFloat = 5.0
    var topMargin: CGFloat!
    var coupon: DiscountCoupon?
    var amount: Double!
    var hideArrow: Bool = false
    
    static let HEIGHT : CGFloat = 86.0
    
    init(frame: CGRect, coupon: DiscountCoupon?, amount:Double, addBorder: Bool = true, topMargin: CGFloat = 20.0, hideArrow: Bool = false) {
        super.init(frame: frame)
        self.coupon = coupon
        self.amount = amount
        self.topMargin = topMargin
        self.hideArrow = hideArrow
        if (self.coupon == nil){
            loadNoCouponView()
        }else{
            loadCouponView()
        }
        if addBorder {
            self.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.px_grayLight(), thickness: 0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadNoCouponView() {
        let currency = MercadoPagoContext.getCurrency()
        let screenWidth = frame.size.width
        let tituloLabel = MPLabel(frame: CGRect(x: margin, y: 20, width: (frame.size.width - 2 * margin), height: 20) )
        tituloLabel.textAlignment = .center;
         let result = NSMutableAttributedString()
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : Utils.getFont(size: 16),NSForegroundColorAttributeName: UIColor.px_grayDark()]
        let total = NSMutableAttributedString(string: "Total: ".localized, attributes: normalAttributes)
        result.append(total)
        result.append(Utils.getAttributedAmount( amount, currency: currency, color : UIColor.px_grayDark(), fontSize: 16, baselineOffset:4))
        tituloLabel.attributedText = result
        let couponFlag = UIImageView()
        couponFlag.image = MercadoPago.getImage("iconDiscount")
        couponFlag.image = couponFlag.image?.withRenderingMode(.alwaysTemplate)
        couponFlag.tintColor = UIColor.primaryColor()
        let rightArrow = UIImageView()
        if !self.hideArrow {
            rightArrow.image = MercadoPago.getImage("rightArrow")
        }
        rightArrow.image = rightArrow.image?.withRenderingMode(.alwaysTemplate)
        rightArrow.tintColor = UIColor.primaryColor()
        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        detailLabel.text = "Tengo un descuento".localized
        detailLabel.textColor = UIColor.primaryColor()
        detailLabel.font = Utils.getFont(size: 16)
        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let totalViewWidth = widthlabelDiscount! + 20 + 8 + 2 * margin
        var x = (screenWidth - totalViewWidth) / 2
        let frameFlag = CGRect(x: x, y: (margin * 2 + 40), width: 20, height: 20)
        couponFlag.frame = frameFlag
        x = x + 20 + margin
        let frameLabel = CGRect(x: x , y: (margin * 2 + 40), width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
         x = x + widthlabelDiscount! + margin
        let frameArrow = CGRect(x: x, y: 4 + (margin * 2 + 40), width: 8, height: 12)
        rightArrow.frame = frameArrow
        self.addSubview(tituloLabel)
        self.addSubview(couponFlag)
        self.addSubview(detailLabel)
        self.addSubview(rightArrow)
    }
    
    
    func loadCouponView() {
        let currency = MercadoPagoContext.getCurrency()
        let screenWidth = frame.size.width
        guard let coupon = self.coupon else {
            return
        }
        let tituloLabel = MPLabel(frame: CGRect(x: margin, y: topMargin, width: (frame.size.width - 2 * margin), height: 20) )
        tituloLabel.textAlignment = .center;
        let result = NSMutableAttributedString()
        let normalAttributes: [String:AnyObject] = [NSFontAttributeName : Utils.getFont(size: 16),NSForegroundColorAttributeName: UIColor.px_grayDark()]
        let total = NSMutableAttributedString(string: "Total: ".localized, attributes: normalAttributes)
        let space = NSMutableAttributedString(string: " ".localized, attributes: normalAttributes)
        let oldAmount = Utils.getAttributedAmount( amount, currency: currency, color : UIColor.px_grayDark(), fontSize: 16, baselineOffset:4)
        oldAmount.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, oldAmount.length))
        let newAmount = Utils.getAttributedAmount( coupon.newAmount(), currency: currency, color : UIColor.mpGreenishTeal(), fontSize: 16, baselineOffset:4)
        result.append(total)
        result.append(oldAmount)
        result.append(space)
        result.append(newAmount)
        tituloLabel.attributedText = result
        let picFlag = UIImageView()
        picFlag.image = MercadoPago.getImage("couponArrowFlag")
        picFlag.image = picFlag.image?.withRenderingMode(.alwaysTemplate)
        picFlag.tintColor = UIColor.mpGreenishTeal()
        let rightArrow = UIImageView()
        
        if !self.hideArrow {
            rightArrow.image = MercadoPago.getImage("rightArrow")
        }
        
        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        if let concept = coupon.concept {
           detailLabel.text = concept
        }else{
           detailLabel.text = "Descuento".localized
        }
        detailLabel.textColor = UIColor.mpGreenishTeal()
        detailLabel.font = Utils.getFont(size: 16)
        let discountAmountLabel = MPLabel()
        discountAmountLabel.textAlignment = .center
        discountAmountLabel.text = coupon.getDiscountDescription()
        discountAmountLabel.backgroundColor = UIColor.mpGreenishTeal()
        discountAmountLabel.textColor = UIColor.white
        discountAmountLabel.font = Utils.getFont(size: 12)
        
        

        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let widthlabelAmount = (discountAmountLabel.attributedText?.widthWithConstrainedHeight(height: 12))! + 10
        let totalViewWidth = widthlabelDiscount! + widthlabelAmount + 10 + 8 + 2 * margin
        var x = (screenWidth - totalViewWidth) / 2
        let frameLabel = CGRect(x: x , y: (margin * 2 + topMargin + 20), width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
        x = x + widthlabelDiscount! + margin
        let framePic = CGRect(x: x, y: (margin * 2 + topMargin + 20), width: 10, height: 19)
        picFlag.frame = framePic
        x = x + 10
        let frameAmountLabel = CGRect(x: x , y: (margin * 2 + topMargin + 20), width: widthlabelAmount, height: 19)
        discountAmountLabel.frame = frameAmountLabel
        x = x + widthlabelAmount + margin
        let frameArrow = CGRect(x: x, y: 4 + (margin * 2 + topMargin + 20), width: 8, height: 12)
        rightArrow.frame = frameArrow
        
        let path = UIBezierPath(roundedRect:discountAmountLabel.bounds,
                                byRoundingCorners:[.topRight, .bottomRight],
                                cornerRadii: CGSize(width: 2, height:  2))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        ///   viewToRound.layer.mask = maskLayer
        
        
        
        discountAmountLabel.layer.mask = maskLayer
        
        self.addSubview(tituloLabel)
        self.addSubview(detailLabel)
        self.addSubview(picFlag)
        self.addSubview(discountAmountLabel)
        self.addSubview(rightArrow)
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        self.addSublayer(border)
    }
}

class DiscountToolBar: UIView {
    var margin : CGFloat = 7.0
    var coupon: DiscountCoupon?
    var amount: Double!
    init(frame: CGRect, coupon: DiscountCoupon?, amount:Double) {
        super.init(frame: frame)
        self.coupon = coupon
        self.amount = amount
        
        self.margin = (frame.size.height - 18 ) / 2
        self.backgroundColor = UIColor.mpGreenishTeal()
        if (self.coupon == nil){
            loadNoCouponView()
        }else{
            loadCouponView()
        }
    }

    
    func loadNoCouponView() {
        let screenWidth = frame.size.width
        let couponFlag = UIImageView()
        couponFlag.image = MercadoPago.getImage("iconDiscount")
        couponFlag.image = couponFlag.image?.withRenderingMode(.alwaysTemplate)
        couponFlag.tintColor = UIColor.white
        let rightArrow = UIImageView()
        rightArrow.image = MercadoPago.getImage("rightArrow")
        rightArrow.image = rightArrow.image?.withRenderingMode(.alwaysTemplate)
        rightArrow.tintColor = UIColor.white
        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        detailLabel.text = "Tengo un descuento".localized
        detailLabel.textColor = UIColor.white
        detailLabel.font = Utils.getFont(size: 16)
        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let totalViewWidth = widthlabelDiscount! + 20 + 8 + 2 * margin
        var x = (screenWidth - totalViewWidth) / 2
        let frameFlag = CGRect(x: x, y: margin , width: 20, height: 20)
        couponFlag.frame = frameFlag
        x = x + 20 + margin
        let frameLabel = CGRect(x: x , y: margin, width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
        x = x + widthlabelDiscount! + margin
        let frameArrow = CGRect(x: x, y: 4 + margin , width: 8, height: 12)
        rightArrow.frame = frameArrow
        self.addSubview(couponFlag)
        self.addSubview(detailLabel)
        self.addSubview(rightArrow)
    }
    
    
    func loadCouponView() {
        let screenWidth = frame.size.width
        guard let coupon = self.coupon else {
            return
        }
        let picFlag = UIImageView()
        picFlag.image = MercadoPago.getImage("couponArrowFlag")
        picFlag.image = picFlag.image?.withRenderingMode(.alwaysTemplate)
        picFlag.tintColor = UIColor.white
        let rightArrow = UIImageView()
        rightArrow.image = MercadoPago.getImage("rightArrow")
        rightArrow.image = rightArrow.image?.withRenderingMode(.alwaysTemplate)
        rightArrow.tintColor = UIColor.white
        let detailLabel = MPLabel()
        detailLabel.textAlignment = .center
        if let concept = coupon.concept {
            detailLabel.text = concept
        }else{
            detailLabel.text = "Descuento".localized
        }
        detailLabel.textColor = UIColor.white
        detailLabel.font = Utils.getFont(size: 16)
        let discountAmountLabel = MPLabel()
        discountAmountLabel.textAlignment = .center
        discountAmountLabel.text = coupon.getDiscountDescription()
        discountAmountLabel.backgroundColor = UIColor.white
        discountAmountLabel.textColor = UIColor.mpGreenishTeal()
        discountAmountLabel.font = Utils.getFont(size: 12)
        let widthlabelDiscount = detailLabel.attributedText?.widthWithConstrainedHeight(height: 18)
        let widthlabelAmount = (discountAmountLabel.attributedText?.widthWithConstrainedHeight(height: 12))! + 8
        let totalViewWidth = widthlabelDiscount! + widthlabelAmount + 10 + 8 + 2 * margin
        var x = (screenWidth - totalViewWidth) / 2
        let frameLabel = CGRect(x: x , y: margin, width: widthlabelDiscount!, height: 18)
        detailLabel.frame = frameLabel
        x = x + widthlabelDiscount! + margin
        let framePic = CGRect(x: x, y: margin, width: 10, height: 19)
        picFlag.frame = framePic
        x = x + 10
        let frameAmountLabel = CGRect(x: x , y: margin, width: widthlabelAmount, height: 19)
        discountAmountLabel.frame = frameAmountLabel
        x = x + widthlabelAmount + margin
        let frameArrow = CGRect(x: x, y: 4 + margin , width: 8, height: 12)
        rightArrow.frame = frameArrow
        self.addSubview(detailLabel)
        self.addSubview(picFlag)
        self.addSubview(discountAmountLabel)
        self.addSubview(rightArrow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension UIView {
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    func round(corners: UIRectCorner, radius: CGFloat) {
        _round(corners: corners, radius: radius)
    }
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func round(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    /**
     Fully rounds an autolayout view (e.g. one with no known frame) with the given diameter and border
     
     - parameter diameter:    The view's diameter
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func fullyRound(diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
    
}

private extension UIView {
    
    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}
