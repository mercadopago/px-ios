//
//  PXLoadingViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 6/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class PXLoadingViewController: UIViewController {
    override func viewDidLoad() {
        _ = PXComponentFactory.Loading.instance().showInView(view)
    }
}
