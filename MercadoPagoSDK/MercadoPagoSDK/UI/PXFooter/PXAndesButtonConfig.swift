//
//  PXAndesButtonConfig.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 02/11/2020.
//

import Foundation
import AndesUI

struct PXAndesButtonConfig {

    let hierarchy: AndesButtonHierarchy
    let size: AndesButtonSize

    init(hierarchy: AndesButtonHierarchy = .quiet, size: AndesButtonSize = .large) {
        self.hierarchy = hierarchy
        self.size = size
    }
}
