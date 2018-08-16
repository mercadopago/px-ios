//
//  MPCustomInflator.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/7/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
@objc
public protocol MPCellContentProvider: NSObjectProtocol {

    func getHeight() -> CGFloat

}
