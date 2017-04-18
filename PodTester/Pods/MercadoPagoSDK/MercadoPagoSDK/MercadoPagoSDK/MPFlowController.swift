//
//  MPFlowController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPFlowController: NSObject {

    internal class func createNavigationControllerWith(_ rootViewController : UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController : rootViewController)
        
        return nav
    }
   
}
