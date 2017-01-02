//
//  ComponentTableViewCell.swift
//  MercadoPagoSDKExamples
//
//  Created by Maria cristina rodriguez on 29/6/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class ComponentTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func initializeWith(_ iconImage: String, title: String){
        var image = UIImage(named: iconImage)
        image = image?.withRenderingMode(.alwaysTemplate)
        self.icon.image = image
        self.icon.tintColor = UIColor.blueMercadoPagoSDK()
        self.title.text = title
    }
    
}
