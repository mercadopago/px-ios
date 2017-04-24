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
    
    var includeOnlinePMS : Bool = true
    var includeOfflinePMS : Bool = true
   
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
            defaultCell.selectionStyle = .none
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
    
    func getSelectorCellFor(selector: Selectors) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        cell.selectionStyle = .none
        let cellFrame = cell.bounds
        
        switch selector {
        case Selectors.site:
            let siteSelector = UISegmentedControl(items: self.getSiteIDs())
            siteSelector.selectedSegmentIndex = 0
            siteSelector.tintColor = UIColor.black
            siteSelector.frame = CGRect(x: cellFrame.minX + 4, y: cellFrame.minY + 4, width: cellFrame.width - 8, height: cellFrame.height-8)
            setSite(sender: siteSelector)
            siteSelector.addTarget(self, action: #selector(setSite(sender: )), for: .valueChanged)
            cell.addSubview(siteSelector)
        case Selectors.enviroment:
            let enviromentSelector = UISegmentedControl(items: self.enviroments)
            enviromentSelector.selectedSegmentIndex = 0
            enviromentSelector.tintColor = UIColor.black
            enviromentSelector.frame = CGRect(x: cellFrame.minX + 4, y: cellFrame.minY + 4, width: cellFrame.width - 8, height: cellFrame.height-8)
            setEnviroment(sender: enviromentSelector)
            enviromentSelector.addTarget(self, action: #selector(setEnviroment(sender: )), for: .valueChanged)
            cell.addSubview(enviromentSelector)
        }
        
        return cell

    }
    
    
    //--Site Selector Logic
    func setSite(sender: UISegmentedControl) {
        let siteID = self.sites[sender.selectedSegmentIndex].ID
        MercadoPagoContext.setSiteID(siteID)
    }
    //Site Selector Logic--
    
    //--Enviroment Selector Logic
    func setEnviroment(sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        let siteID = self.sites[sender.selectedSegmentIndex].ID

        switch title {
        case Enviroments.production.rawValue:
            let pk = self.getPublicKey(site: siteID, sandbox: false)
            MercadoPagoContext.setPublicKey(pk)
        case Enviroments.sandbox.rawValue:
            let pk = self.getPublicKey(site: siteID, sandbox: true)
            MercadoPagoContext.setPublicKey(pk)
        default:
            let pk = self.getPublicKey(site: siteID, sandbox: true)
            MercadoPagoContext.setPublicKey(pk)
        }
    }
    //Enviroment Selector Logic--
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func getSwitchCellFor(forSwitch: Switches) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.frame.size.height = 40
        let cellFrame = cell.bounds
        let view = UIView()
        view.frame = CGRect(x: cellFrame.minX, y: cellFrame.minY, width: cellFrame.width, height: cellFrame.height)
        let viewFrame = view.bounds
        let cellSwitch = UISwitch()
        cellSwitch.setOn(true, animated: false)
        cellSwitch.frame = CGRect(x: viewFrame.maxX - cellSwitch.frame.width - 10, y: viewFrame.midY - (cellSwitch.frame.height/2), width: cellSwitch.frame.width, height: cellSwitch.frame.height)
        view.addSubview(cellSwitch)
        
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = forSwitch.rawValue


        cell.selectionStyle = .none
        cell.addSubview(view)
        return cell

    }
    

    
    func getColorPickerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.frame.size.height = 80
        
        let cellFrame = cell.bounds
        
        
        let view = UIView()
        view.frame = CGRect(x: cellFrame.minX + 4, y: cellFrame.minY + 44, width: cellFrame.width - 8, height: cellFrame.height - 48)
        
        view.backgroundColor = self.getColor(site: "MLU")
        
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
            let pkSandbox = getPublicKey(site: siteID as! String, sandbox: true)
            let pkProdu = getPublicKey(site: siteID as! String, sandbox: false)
            let color = getColor(site: siteID as! String)
            
            let site = Site(ID: siteID as! String, name: name, prefID: prefId, pk_sandbox: pkSandbox, pk_produ: pkProdu, defaultColor: color)
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
    
    open func getPublicKey(site: String, sandbox: Bool) -> String{
        let default_MLA_PK = ""
        let dictionary = getEnviromentSettings(site: site)
        
        if let PK = sandbox ? dictionary.value(forKey: "pk_sandbox") : dictionary.value(forKey: "pk_produ") {
            return PK as! String
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



