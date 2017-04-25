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
    open let environments: [String] = [Environments.sandbox.rawValue, Environments.production.rawValue]
    
    var selectedSite : Site!
    var selectedEnvironment : Environments = Environments.sandbox
    var selectedColor : UIColor!
    var includeOnlinePMS : Bool = true
    var includeOfflinePMS : Bool = true
    
    let marginSpace: CGFloat = 10
   
    let Mainframe = UIScreen.main.bounds

    
    //--TableView Build Logic
    open func getNumberOfRowsInSection(section: Int) -> Int{
        return 5
    }
    
    open func getCellFor(indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case Cells.siteSelector.rawValue:
            return getSelectorCellFor(selector: Selectors.site)
        case Cells.environmentSelector.rawValue:
            return getSelectorCellFor(selector: Selectors.environment)
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
        return 40
    }
    //TableView Build Logic--
    
    
    
    //--Selector Cell Creator
    func getSelectorCellFor(selector: Selectors) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.frame.size.width = Mainframe.width
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
        case Selectors.environment:
            let environmentSelector = UISegmentedControl(items: self.environments)
            environmentSelector.selectedSegmentIndex = 0
            environmentSelector.tintColor = UIColor.black
            environmentSelector.frame = selectorFrame
            setEnvironment(sender: environmentSelector)
            environmentSelector.addTarget(self, action: #selector(setEnvironment(sender: )), for: .valueChanged)
            cell.addSubview(environmentSelector)
        }
        
        return cell

    }
    //Selector Cell Creator--
    
    
    
    //--Site Selector Logic
    func setSite(sender: UISegmentedControl) {
        let siteID = self.sites[sender.selectedSegmentIndex].ID
        self.selectedSite = getSitefromID(siteID: siteID)
        self.selectedColor = selectedSite.getColor()
    }
    //Site Selector Logic--
    
    
    
    //--Environment Selector Logic
    func setEnvironment(sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)!

        switch title {
        case Environments.production.rawValue:
            self.selectedEnvironment = Environments.production
        case Environments.sandbox.rawValue:
            self.selectedEnvironment = Environments.sandbox
        default:
            self.selectedEnvironment = Environments.sandbox
        }
    }
    //Environment Selector Logic--
    
    
    
    //--Payment Methods Exclusion Logic
    func getSwitchCellFor(forSwitch: Switches) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.frame.size.width = Mainframe.width
        cell.selectionStyle = .none
        let cellFrame = cell.bounds
        
        let cellSwitch = UISwitch()
        cellSwitch.setOn(true, animated: false)
        cellSwitch.frame = CGRect(x: cellFrame.maxX - cellSwitch.frame.width - marginSpace, y: cellFrame.midY - (cellSwitch.frame.height/2), width: cellSwitch.frame.width, height: cellSwitch.frame.height)
        cell.addSubview(cellSwitch)
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = forSwitch.rawValue
        
        setOnlinePaymentMethods(sender: cellSwitch)
        setOfflinePaymentMethods(sender: cellSwitch)
        
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
    
    
    
    //--Color Picker Logic
    func getColorPickerCell() -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.frame.size.width = Mainframe.width
        cell.selectionStyle = .none
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = "Custom Color"
        
        let cellFrame = cell.bounds
        
        let cellTextfield = UITextField()
        cellTextfield.frame = CGRect(x: cellFrame.midX + marginSpace/2, y: cellFrame.minY + marginSpace/2, width: cellFrame.width/2 - marginSpace, height: cellFrame.height - marginSpace)
        cellTextfield.layer.borderWidth = 1
        cellTextfield.layer.cornerRadius = 5
        cellTextfield.placeholder = "#FFFFFF"
        cellTextfield.autocapitalizationType = .allCharacters
        cellTextfield.addTarget(self, action: #selector(setSelectedColor(sender: )), for: UIControlEvents.allEditingEvents)
        cell.addSubview(cellTextfield)
        
        return cell
    }
    
    
    func setSelectedColor(sender: UITextField) {
        selectedColor = UIColor.fromHex(sender.text!)
    }
    //Color Picker Logic--
    

    //Updates build settings bearing in mind the customization factors
    open func update(){
        MercadoPagoContext.setSiteID(selectedSite.ID)
        selectedSite.pk = getPublicKey(site: selectedSite.ID)
        MercadoPagoContext.setPublicKey(selectedSite.pk)
        selectedSite.pref_ID = getPrefID(site: selectedSite.ID)
    }
    
    //Return NSDictionary from requested Plist
    func getDictionaryFrom(plist: String) -> NSDictionary? {
        let path = Bundle.main.path(forResource: "EnvironmentSettings", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        return dictionary!
    }
    
    //Load Sites from plist to local variable
    open func loadSites() {
        let dictionary = getDictionaryFrom(plist: "EnvironmentSettings")
        let keys = dictionary?.allKeys
        
        for siteID in keys! {
            if siteID as! String != "default" {
                let name = getName(site: siteID as! String)
                let prefId = getPrefID(site: siteID as! String)
                let pk = getPublicKey(site: siteID as! String)
                let color = getColor(site: siteID as! String)
                
                let site = Site(ID: siteID as! String, name: name, prefID: prefId, publicKey: pk, defaultColor: color)
                self.sites.append(site)
            }
        }
    }
    
    //Returns Array of available Sites
    open func getSites() -> [Site] {
        if sites.isEmpty {
            loadSites()
        }
        return sites
    }
    
    //Returns Array of available Sites IDs
    open func getSiteIDs() -> [String] {
        let sites = getSites()
        var sitesIDs : [String] = []
        for site in sites {
            let siteID = site.ID
            sitesIDs.append(siteID)
        }
        return sitesIDs
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

    //Returns Environment Settings for the requested Site
    private func getEnvironmentSettings(site: String) -> NSDictionary{
        let dictionary = getDictionaryFrom(plist: "EnvironmentSettings")
        
        if let siteDictionary = dictionary?.value(forKey: site) {
            return siteDictionary as! NSDictionary
        } else {
            return dictionary?.value(forKey: "default") as! NSDictionary
        }
        
        
    }
    
    //Returns Requested PrefID
    func prefIdFinder(site: String, forValue: String) -> String {
        var dictionary = getEnvironmentSettings(site: site)
        
        if let prefID = dictionary.value(forKey: forValue) {
            return prefID as! String
        } else {
            dictionary = getEnvironmentSettings(site: "default")
            return dictionary.value(forKey: forValue) as! String
        }
    }
    
    //Returns a PrefID bearing in mind the customization factors
    open func getPrefID(site: String) -> String{
        if includeOnlinePMS && includeOfflinePMS {
            return prefIdFinder(site: site, forValue: "pref_ID")
        } else if  !includeOnlinePMS && includeOfflinePMS{
            return prefIdFinder(site: site, forValue: "pref_ID_excl_online")
        }else {
            return prefIdFinder(site: site, forValue: "pref_ID_excl_offline")
        }
    }
    
    //Returns a Public Key bearing in mind the customization factors
    open func getPublicKey(site: String) -> String{
        var dictionary = getEnvironmentSettings(site: site)
        
        switch self.selectedEnvironment {
        case Environments.production:
            if let Pk = dictionary.value(forKey: "pk_produ") {
                return Pk as! String
            } else {
                dictionary = getEnvironmentSettings(site: "default")
                return dictionary.value(forKey: "pk_produ") as! String
            }
            
        case Environments.sandbox:
            if let Pk = dictionary.value(forKey: "pk_sandbox") {
                return Pk as! String
            } else {
                dictionary = getEnvironmentSettings(site: "default")
                return dictionary.value(forKey: "pk_sandbox") as! String
            }
        }
    }
    
    //Returns Name for the requested SiteID
    open func getName(site: String) -> String {
        var dictionary = getEnvironmentSettings(site: site)
        
        if let name = dictionary.value(forKey: "name") {
            return name as! String
        } else {
            dictionary = getEnvironmentSettings(site: "default")
            return dictionary.value(forKey: "name") as! String
        }
    }
    
    //Returns Color for the requested SiteID
    open func getColor(site: String) -> UIColor {
        var dictionary = getEnvironmentSettings(site: site)
        
        if let color = dictionary.value(forKey: "default_color") {
            return UIColor.fromHex(color as! String)
        } else {
            dictionary = getEnvironmentSettings(site: "default")
            return UIColor.fromHex(dictionary.value(forKey: "default_color") as! String)
        }
    }

    public enum Cells : Int {
        case siteSelector = 0
        case environmentSelector = 1
        case onlinePMs = 2
        case offlinePMS = 3
        case colorPicker = 4
    }
    
    public enum Environments : String {
        case sandbox = "Sandbox"
        case production = "Production"
    }
    
    public enum Selectors : String {
        case site = "site"
        case environment = "environment"
    }
    
    public enum Switches : String {
        case OnlinePaymentMethods = "Online Payment Methods"
        case OfflinePaymentMethods = "Offline Payment Methods"
    }
}



