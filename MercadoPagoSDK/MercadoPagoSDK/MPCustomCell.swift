//
//  CellProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 2/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

import Foundation

@objcMembers
open class MPCustomCell: NSObject {

    weak var delegate: MPCustomRowDelegate?

    private var cell: UITableViewCell!

    public init(cell: UITableViewCell) {
        self.cell = cell
    }

    public func getHeight() -> CGFloat {
        if let contentProvider = self.getTableViewCell() as? MPCellContentProvider {
            return contentProvider.getHeight()
        }
        return 0
    }

    public func setDelegate(delegate: MPCustomRowDelegate) {
        self.delegate = delegate
    }

    public func getDelegate() -> MPCustomRowDelegate {
        return self.delegate!
    }

    public func getTableViewCell() -> UITableViewCell {
        return self.cell
    }
}
