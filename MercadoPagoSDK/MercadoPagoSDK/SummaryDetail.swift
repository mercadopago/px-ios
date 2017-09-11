//
//  SummaryDetail.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 9/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class SummaryDetail: NSObject {
    var title : String
    var details : [AmountDetail]
    var titleColor = UIColor.px_grayDark()
    var amountColor = UIColor.px_grayDark()
    func getTotalAmount() -> Double {
        var sum : Double = 0
        for detail in details {
            sum = sum + detail.amount
        }
        return sum
    }
    init(title: String, detail: AmountDetail?) {
        self.title = title
        self.details = [AmountDetail]()
        if let detail = detail {
            self.details.append(detail)
        }
    }
    func addDetail(amountDetail : AmountDetail){
        self.details.append(amountDetail)
    }
}
