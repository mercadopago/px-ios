//
//  PXPointsProgress.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

@objcMembers
public class PXPointsProgress: NSObject, Decodable {

    let percentage: Double
    let levelColor: String
    let levelNumber: Int
    
    public init(percentage: Double, levelColor: String, levelNumber: Int) {
        self.percentage = percentage
        self.levelColor = levelColor
        self.levelNumber = levelNumber
    }

    enum CodingKeys: String, CodingKey {
        case percentage
        case levelColor = "level_color"
        case levelNumber = "level_number"
    }
}
