//
//  Cellable.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 3/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

public protocol Cellable{
    
    func getCell(width: Double, height: Double)-> UITableViewCell

}

