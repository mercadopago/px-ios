//
//  RejectedPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RejectedPaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {

    static let ROW_HEIGHT = CGFloat(186)
    
    
    @IBOutlet weak var title: MPLabel!
    
    @IBOutlet weak var subtitle: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.addCharactersSpacing(-0.4)
        self.layer.shadowOffset = CGSizeMake(0, 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).CGColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(payment : Payment, paymentMethod : PaymentMethod, callback : (Void -> Void)?) -> UITableViewCell {
        
        
        let title = ((payment.statusDetail + "_title").localized  as NSString).stringByReplacingOccurrencesOfString("%0", withString: "\(paymentMethod.name)")
        self.title.text = title
        let subtitle = ((payment.statusDetail + "_subtitle_" + paymentMethod.paymentTypeId.rawValue).localized  as NSString).stringByReplacingOccurrencesOfString("%0", withString: "\(paymentMethod.name)")
        self.subtitle.text = subtitle
        return self
    }
 
}
