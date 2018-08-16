//
//  PXInstructionsSecondaryInfoComponent.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/15/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

/** :nodoc: */
public class PXInstructionsSecondaryInfoComponent: NSObject, PXComponentizable {
    var props: PXInstructionsSecondaryInfoProps

    init(props: PXInstructionsSecondaryInfoProps) {
        self.props = props
    }
    public func render() -> UIView {
        return PXInstructionsSecondaryInfoRenderer().render(instructionsSecondaryInfo: self)
    }
}

/** :nodoc: */
public class PXInstructionsSecondaryInfoProps: NSObject {
    var secondaryInfo: [String]
    init(secondaryInfo: [String]) {
        self.secondaryInfo = secondaryInfo
    }
}
