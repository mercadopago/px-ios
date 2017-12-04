//
//  HooksNavigationManager.swift
//  PodTester
//
//  Created by Juan sebastian Sanzone on 4/12/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import MercadoPagoSDK

class HooksNavigationManager {
    
    let hooksStoryboard = UIStoryboard(name: "Hooks", bundle: nil)
    
    func getFirstHook() -> FirstHookViewController {
        return hooksStoryboard.instantiateViewController(withIdentifier: "firstHook") as! FirstHookViewController
    }
    
    func getSecondHook() -> SecondHookViewController {
        return hooksStoryboard.instantiateViewController(withIdentifier: "secondHook") as! SecondHookViewController
    }
    
    func getThirdHook() -> ThirdHookViewController {
        return hooksStoryboard.instantiateViewController(withIdentifier: "thirdHook") as! ThirdHookViewController
    }
}
