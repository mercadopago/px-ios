//
//  PaymentSearchCollectionViewCell.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentSearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet weak var titleSearch: UILabel!
    @IBOutlet weak var subtitleSearch: UILabel!
    

    @IBOutlet weak var titleConstraints: NSLayoutConstraint!
    @IBOutlet weak var subtitleConstraints: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    public func fillCell(image: UIImage?, title: String? = "", subtitle: String? = ""){
        
        self.titleSearch.text = title
        self.titleSearch.font = Utils.getFont(size: titleSearch.font.pointSize)
        self.subtitleSearch.text = subtitle
        self.subtitleSearch.font = Utils.getFont(size: subtitleSearch.font.pointSize)
        self.imageSearch.image = image

        self.backgroundColor = UIColor.px_white()
        self.titleSearch.textColor = UIColor.black
        self.layoutIfNeeded()
    }
    
    func getConstraintFor(label : UILabel) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.subtitleSearch, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: label.requiredHeight())
    }
    
    
    
    func totalHeight() -> CGFloat {
        return titleSearch.requiredHeight() + subtitleSearch.requiredHeight() + 112
    }
    
    func fillCell(drawablePaymentOption : PaymentOptionDrawable) {
        let image = MercadoPago.getImageForPaymentMethod(withDescription: drawablePaymentOption.getImageDescription())
  
        self.fillCell(image: image, title: drawablePaymentOption.getTitle(), subtitle: drawablePaymentOption.getSubtitle())
    }
    func fillCell(optionText : String) {
        self.fillCell(image: nil, title:optionText, subtitle: nil)
    }

    static func totalHeight(drawablePaymentOption : PaymentOptionDrawable) -> CGFloat {
        return PaymentSearchCollectionViewCell.totalHeight(title: drawablePaymentOption.getTitle(), subtitle: drawablePaymentOption.getSubtitle())
    }
    
    static func totalHeight(title: String?, subtitle:String?) -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let availableWidth = screenWidth - (screenWidth * 0.3)
        let widthPerItem = availableWidth / 2
        
        let titleLabel = UILabel(frame: CGRect(x:0,y:0,width:widthPerItem,height:0))
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.text = title
        let subtitleLabel = UILabel(frame: CGRect(x:0,y:0,width:widthPerItem,height:0))
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.text = subtitle
        let altura1 = titleLabel.requiredHeight()
        let altura2 = subtitleLabel.requiredHeight()
        return altura1 + altura2 + 112
    }
}


