//
//  Updatable.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/9/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

public protocol Updatable {

    func updateCard(token: CardInformationForm?, paymentMethod: PaymentMethod)

    func setCornerRadius(radius: CGFloat)

}
