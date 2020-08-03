//
//  PXPoints.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

@objcMembers
public class PXPoints: NSObject, Decodable {

    let progress: PXPointsProgress
    let title: String
    let action: PXRemoteAction
    
    public init(progress:PXPointsProgress, title: String, action: PXRemoteAction) {
        self.progress = progress
        self.title = title
        self.action = action
    }

    enum CodingKeys: String, CodingKey {
        case progress
        case title
        case action
    }
}

