//
//  PXTotalRowProps.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

final class PXTotalRowProps: NSObject {
    var title: NSAttributedString?
    var disclaimer: NSAttributedString?
    var mainValue: NSAttributedString?
    var secondaryValue: NSAttributedString?
    var showChevron: Bool

    init(title: NSAttributedString?, disclaimer: NSAttributedString?, mainValue: NSAttributedString?, secondaryValue: NSAttributedString?, showChevron: Bool = true) {
        self.title = title
        self.disclaimer = disclaimer
        self.mainValue = mainValue
        self.secondaryValue = secondaryValue
        self.showChevron = showChevron
    }
}
