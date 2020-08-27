//
//  PXDownloadAction.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/09/2019.
//

import Foundation

@objcMembers
public class PXDownloadAction: NSObject, Decodable {
    let title: String
    let action: PXRemoteAction
    
    public init(title:String, action: PXRemoteAction) {
        self.title = title
        self.action = action
    }
}
