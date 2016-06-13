//
//  MPFlowController.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class MPFlowController: NSObject {

    public class func createNavigationControllerWith(rootViewController : UIViewController) -> MPNavigationController {
        
        let nav = MPNavigationController(rootViewController : rootViewController)
        
        return nav
    }
   
}
