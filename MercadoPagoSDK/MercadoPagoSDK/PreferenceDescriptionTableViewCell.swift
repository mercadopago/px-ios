//
//  PreferenceDescriptionCellTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 4/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PreferenceDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var preferenceDescription: MPLabel!
    
    @IBOutlet weak var shoppingCartIcon: UIImageView!
    @IBOutlet weak var preferenceAmount: MPLabel!

    @IBOutlet weak var shoppingCartIconContainer: UIView!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tintedImage = self.shoppingCartIcon.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.shoppingCartIcon.image = tintedImage
        self.shoppingCartIcon.tintColor = UIColor().white()
        
        self.shoppingCartIconContainer.layer.borderWidth = 1.0
        self.shoppingCartIconContainer.layer.borderColor = UIColor.whiteColor().CGColor
        
    
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func fillRowWithPreference(preference : CheckoutPreference){
        let currency = CurrenciesUtil.getCurrencyFor(preference.getCurrencyId())
        self.fillRowWithSettings(preference.getAmount(), purchaseTitle: preference.getTitle(), pictureUrl: preference.getPictureUrl(), currency : currency!)
        
    }
    
    internal func fillRowWithSettings(amount : Double, purchaseTitle: String? = "", pictureUrl : String? = "", currency : Currency){
        self.preferenceAmount.attributedText = Utils.getAttributedAmount(amount, thousandSeparator: String(currency.getThousandsSeparatorOrDefault()), decimalSeparator: String(currency.getDecimalSeparatorOrDefault()), currencySymbol: String(currency.getCurrencySymbolOrDefault()))
        self.preferenceDescription.text = purchaseTitle
        if  !String.isNullOrEmpty(pictureUrl) {
            if self.shoppingCartIconContainer.subviews.count == 0 {
                self.shoppingCartIcon.removeFromSuperview()
                ViewUtils.loadImageFromUrl(pictureUrl!, inView: self.shoppingCartIconContainer)
            }
        }
        
    }
    
    public func loadPreference(preference: CheckoutPreference!){
       
        
    }
    
}
