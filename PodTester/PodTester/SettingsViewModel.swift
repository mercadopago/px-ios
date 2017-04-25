//
//  SettingsViewModel.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/18/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import Foundation
import UIKit
import MercadoPagoSDK

open class SettingsViewModel: NSObject {
    
    open var sites: [Site] = []
    open let enviroments: [String] = [Enviroments.sandbox.rawValue, Enviroments.production.rawValue]
    
    var selectedSite : Site!
    var selectedEnviroment : Enviroments = Enviroments.sandbox
    var includeOnlinePMS : Bool = true
    var includeOfflinePMS : Bool = true
    
    let marginSpace: CGFloat = 10
   
    //Number of Row in the Settings TableView
    open func getNumberOfRowsInSection(section: Int) -> Int{
        return 5
    }
    
    open func getCellFor(indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case Cells.siteSelector.rawValue:
            return getSelectorCellFor(selector: Selectors.site)
        case Cells.enviromentSelector.rawValue:
            return getSelectorCellFor(selector: Selectors.enviroment)
        case Cells.onlinePMs.rawValue:
            return getSwitchCellFor(forSwitch: Switches.OnlinePaymentMethods)
        case Cells.offlinePMS.rawValue:
            return getSwitchCellFor(forSwitch: Switches.OfflinePaymentMethods)
        case Cells.colorPicker.rawValue:
            return getColorPickerCell()
        default:
            let defaultCell = UITableViewCell()
            return defaultCell
        }
    }
    
    open func getHeightFor(indexPath: IndexPath) -> CGFloat{
        switch indexPath.row {
        case Cells.colorPicker.rawValue:
            return 80
        default:
            return 40
        }
    }
    
    
    
    //--Selector Cell Creator
    func getSelectorCellFor(selector: Selectors) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.selectionStyle = .none
        let cellFrame = cell.bounds
        
        let selectorFrame = CGRect(x: cellFrame.minX + marginSpace/2, y: cellFrame.minY + marginSpace/2, width: cellFrame.width - marginSpace, height: cellFrame.height - marginSpace)
        
        switch selector {
        case Selectors.site:
            let siteSelector = UISegmentedControl(items: self.getSiteIDs())
            siteSelector.selectedSegmentIndex = 0
            siteSelector.tintColor = UIColor.black
            siteSelector.frame = selectorFrame
            setSite(sender: siteSelector)
            siteSelector.addTarget(self, action: #selector(setSite(sender: )), for: .valueChanged)
            cell.addSubview(siteSelector)
        case Selectors.enviroment:
            let enviromentSelector = UISegmentedControl(items: self.enviroments)
            enviromentSelector.selectedSegmentIndex = 0
            enviromentSelector.tintColor = UIColor.black
            enviromentSelector.frame = selectorFrame
            setEnviroment(sender: enviromentSelector)
            enviromentSelector.addTarget(self, action: #selector(setEnviroment(sender: )), for: .valueChanged)
            cell.addSubview(enviromentSelector)
        }
        
        return cell

    }
    //Selector Cell Creator--
    
    
    
    //--Site Selector Logic
    func setSite(sender: UISegmentedControl) {
        let siteID = self.sites[sender.selectedSegmentIndex].ID
        self.selectedSite = getSitefromID(siteID: siteID)
    }
    //Site Selector Logic--
    
    
    
    //--Enviroment Selector Logic
    func setEnviroment(sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)!

        switch title {
        case Enviroments.production.rawValue:
            self.selectedEnviroment = Enviroments.production
        case Enviroments.sandbox.rawValue:
            self.selectedEnviroment = Enviroments.sandbox
        default:
            self.selectedEnviroment = Enviroments.sandbox
        }
    }
    //Enviroment Selector Logic--
    
    
    
    //--Payment Methods Exclusion Logic
    func getSwitchCellFor(forSwitch: Switches) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.selectionStyle = .none
        let cellFrame = cell.bounds
        
        let cellSwitch = UISwitch()
        cellSwitch.setOn(true, animated: false)
        cellSwitch.frame = CGRect(x: cellFrame.maxX - cellSwitch.frame.width - marginSpace, y: cellFrame.midY - (cellSwitch.frame.height/2), width: cellSwitch.frame.width, height: cellSwitch.frame.height)
        cell.addSubview(cellSwitch)
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = forSwitch.rawValue
        
        switch forSwitch {
        case Switches.OnlinePaymentMethods:
            cellSwitch.addTarget(self, action: #selector(setOnlinePaymentMethods(sender: )), for: .valueChanged)
            
        case Switches.OfflinePaymentMethods:
            cellSwitch.addTarget(self, action: #selector(setOfflinePaymentMethods(sender: )), for: .valueChanged)
        }
        
        return cell

    }
    
    func setOnlinePaymentMethods(sender: UISwitch) {
        if sender.isOn {
            includeOnlinePMS = true
        } else {
            if includeOfflinePMS == true {
                includeOnlinePMS = false
            } else {
                includeOnlinePMS = true
                sender.setOn(true, animated: true)
            }
        }
    }
    
    func setOfflinePaymentMethods(sender: UISwitch) {
        if sender.isOn {
            includeOfflinePMS = true
        } else {
            if includeOnlinePMS == true {
                includeOfflinePMS = false
            } else {
                includeOfflinePMS = true
                sender.setOn(true, animated: true)
            }
        }
    }
    //Payment Methods Exclusion Logic--
    
    
    
    open func update(){
        MercadoPagoContext.setSiteID(selectedSite.ID)
        selectedSite.pk = getPublicKey(site: selectedSite.ID)
        MercadoPagoContext.setPublicKey(selectedSite.pk)
        
        selectedSite.pref_ID = getPrefID(site: selectedSite.ID)
    }
    
    
    
    
    
    
    

    
    func getColorPickerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.frame.size.height = 80
        
        let cellFrame = cell.bounds
        
        
        let view = UIView()
        view.frame = CGRect(x: cellFrame.minX + marginSpace/2, y: cellFrame.minY + marginSpace/2, width: cellFrame.height - marginSpace, height: cellFrame.height - marginSpace)
        
        view.backgroundColor = self.selectedSite.getColor()
        
        cell.selectionStyle = .none
        cell.addSubview(view)
        return cell
    }
    
    
    //Get Site From Site ID. E.G: "MLA"
    open func getSitefromID(siteID: String) -> Site? {
        let sites = getSites()
        for site in sites {
            if site.ID == siteID {
                return site
            }
        }
        
        return nil
    }
    
    //Load Sites from plist to local variable
    open func loadSites() {
        let path = Bundle.main.path(forResource: "EnviromentSettings", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let keys = dictionary?.allKeys
        
        for siteID in keys! {
            
            let name = getName(site: siteID as! String)
            let prefId = getPrefID(site: siteID as! String)
            let pk = getPublicKey(site: siteID as! String)
            let color = getColor(site: siteID as! String)
            
            let site = Site(ID: siteID as! String, name: name, prefID: prefId, publicKey: pk, defaultColor: color)
            self.sites.append(site)
        }
    }
    
    
    open func getSites() -> [Site] {
        if sites.isEmpty {
            loadSites()
        }
        return sites
    }
    
    open func getSiteIDs() -> [String] {
        let sites = getSites()
        var sitesIDs : [String] = []
        for site in sites {
            let siteID = site.ID
            sitesIDs.append(siteID)
        }
        return sitesIDs
    }

    private func getEnviromentSettings(site: String) -> NSDictionary{
        let path = Bundle.main.path(forResource: "EnviromentSettings", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let siteDictionary = dictionary?.value(forKey: site)
        
        return siteDictionary as! NSDictionary
    }
    
    func prefIdFinder(site: String, forValue: String) -> String {
        let dictionary = getEnviromentSettings(site: site)
        
        if let prefID = dictionary.value(forKey: forValue) {
            return prefID as! String
        } else {
            let dictionary = getEnviromentSettings(site: "default")
            return dictionary.value(forKey: "pref_ID") as! String
        }
    }
    
    open func getPrefID(site: String) -> String{
        if includeOnlinePMS && includeOfflinePMS {
            return prefIdFinder(site: site, forValue: "pref_ID")
        } else if  !includeOnlinePMS && includeOfflinePMS{
            return prefIdFinder(site: site, forValue: "pref_ID_excl_online")
        }else {
            return prefIdFinder(site: site, forValue: "pref_ID_excl_offline")
        }
    }
    
    open func getPublicKey(site: String) -> String{
        let default_MLA_PK = ""
        let dictionary = getEnviromentSettings(site: site)
        
        switch self.selectedEnviroment {
        case Enviroments.production:
            if let Pk = dictionary.value(forKey: "pk_produ") {
                return Pk as! String
            }
        case Enviroments.sandbox:
            if let Pk = dictionary.value(forKey: "pk_sandbox") {
                return Pk as! String
            }
        }
        
        return default_MLA_PK
    }
    
    open func getName(site: String) -> String {
        let default_MLA_name = "Argentina"
        let dictionary = getEnviromentSettings(site: site)
        
        if let name = dictionary.value(forKey: "name") {
            return name as! String
        }
        
        return default_MLA_name
    }
    
    open func getColor(site: String) -> UIColor {
        let default_MLA_color = UIColor.fromHex("3D4064")
        let dictionary = getEnviromentSettings(site: site)
        
        if let color = dictionary.value(forKey: "default_color") {
            return UIColor.fromHex(color as! String)
        }
        
        return default_MLA_color
    }

    public enum Cells : Int {
        case siteSelector = 0
        case enviromentSelector = 1
        case onlinePMs = 2
        case offlinePMS = 3
        case colorPicker = 4
    }
    
    public enum Enviroments : String {
        case sandbox = "Sandbox"
        case production = "Production"
    }
    
    public enum Selectors : String {
        case site = "site"
        case enviroment = "enviroment"
    }
    
    public enum Switches : String {
        case OnlinePaymentMethods = "Online Payment Methods"
        case OfflinePaymentMethods = "Offline Payment Methods"
    }
}



