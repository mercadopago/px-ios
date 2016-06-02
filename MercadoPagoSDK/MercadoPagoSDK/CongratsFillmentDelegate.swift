//
//  CongratsFillmentDelegate.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 10/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

protocol CongratsFillmentDelegate {

    func fillCell(payment : Payment, paymentMethod: PaymentMethod, callback : (Void -> Void)?) -> UITableViewCell
}
