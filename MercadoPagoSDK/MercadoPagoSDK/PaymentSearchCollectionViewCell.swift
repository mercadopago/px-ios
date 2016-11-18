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
        self.subtitleSearch.text = subtitle
        self.imageSearch.image = image

        self.titleSearch.textColor = MercadoPagoContext.getTextColor()
        self.layoutIfNeeded()
    }
    
    func getConstraintFor(label : UILabel) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.subtitleSearch, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: label.requiredHeight())
    }
    
    
    
    func totalHeight() -> CGFloat {
        return titleSearch.requiredHeight() + subtitleSearch.requiredHeight() + 112
    }
    public func fillCell(searchItem : PaymentMethodSearchItem){
        let image = MercadoPago.getImageFor(searchItem: searchItem)
        self.fillCell(image: image, title: searchItem.description, subtitle: searchItem.comment)
    }
    
    public func fillCell(cardInformation : CardInformation){
        let image = MercadoPago.getImageFor(cardInformation: cardInformation)
        self.fillCell(image: image, title: cardInformation.getCardDescription(), subtitle: nil)
    }
    
    static func totalHeight(searchItem : PaymentMethodSearchItem ) -> CGFloat {
        return PaymentSearchCollectionViewCell.totalHeight(title: searchItem.description, subtitle: searchItem.comment)
    }
    static func totalHeight(title: String?, subtitle:String?) -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let availableWidth = screenWidth - 32
        let widthPerItem = availableWidth / 2
        
        let titleLabel = UILabel(frame: CGRect(x:0,y:0,width:widthPerItem,height:0))
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = title
        let subtitleLabel = UILabel(frame: CGRect(x:0,y:0,width:widthPerItem,height:0))
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.text = subtitle
        let altura1 = titleLabel.requiredHeight()
        let altura2 = subtitleLabel.requiredHeight()
    return altura1 + altura2 + 112
    }
}


