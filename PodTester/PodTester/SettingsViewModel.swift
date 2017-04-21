//
//  SettingsViewModel.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/18/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation

open class SettingsViewModel: NSObject {
    
    open let sites: [String] = ["MLA", "MLU", "MLB", "MPE", "MLV", "MCO", "MLC"]
    open let enviroments: [String] = ["Sandbox","Producción"]
    open var selectedEnviroment : String!
    

    private func getEnviromentSettings(site: String) -> NSDictionary{
        let path = Bundle.main.path(forResource: "EnviromentSettings", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let siteDictionary = dictionary?.value(forKey: site)
        
        return siteDictionary as! NSDictionary
    }
    
    open func getPrefID(site: String) -> String{
        let default_MLA_PREF_ID = ""
        let dictionary = getEnviromentSettings(site: site)
        
        if let prefID = dictionary.value(forKey: "pref_ID") {
            return prefID as! String
        }
        
        return default_MLA_PREF_ID
    }
    
    open func getPublicKey(site: String, sandbox: Bool) -> String{
        let default_MLA_PK = ""
        let dictionary = getEnviromentSettings(site: site)
        
        if let PK = sandbox ? dictionary.value(forKey: "pk_sandbox") : dictionary.value(forKey: "pk_produ") {
            return PK as! String
        }
        
        return default_MLA_PK
    }
}

