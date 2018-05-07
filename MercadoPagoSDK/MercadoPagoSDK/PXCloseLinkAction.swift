//
//  PXCloseLinkAction.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 25/4/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXCloseLinkAction: PXComponentAction {

    init() {
        super.init(label: PXFooterResultConstants.DEFAULT_LINK_TEXT.localized) {
            PXNotificationManager.Post.attemptToClose()
        }
    }
}
