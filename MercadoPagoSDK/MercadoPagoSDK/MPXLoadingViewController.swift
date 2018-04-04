//
//  MPXLoadingViewController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/16/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

class MPXLoadingViewController: MercadoPagoUIViewController {

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MercadoPagoCheckout.firstViewControllerPushed = false
    }
}
