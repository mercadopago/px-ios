//
//  SettingsViewController.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/18/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

open class SettingsViewController: UIViewController{
    let viewModel = SettingsViewModel()
    let frame = UIScreen.main.bounds
    var siteSelector = UISegmentedControl()
    var enviromentSelector = UISegmentedControl()
    
    @IBOutlet weak var continueButton: UIButton!
    
    
    override open func viewDidLoad() {
        drawSiteSelector()
        drawEnviromentSelector()
        drawOnlinePMsSwitchView()
        drawOfflinePMsSwitchView()
        drawAccountMoneySwitchView()
        drawContinueButton()
        self.title = "Settings"
    }
    
    func drawSiteSelector(){
        siteSelector = UISegmentedControl(items: self.viewModel.sites)
        siteSelector.selectedSegmentIndex = 0
        siteSelector.tintColor = UIColor.black
        setSite()
        siteSelector.frame = CGRect(x: frame.minX + 10, y: frame.minY + 70, width: frame.width - 20, height: frame.height*0.06)
        self.view.addSubview(siteSelector)
        siteSelector.addTarget(self, action: #selector(changeSite(sender: )), for: .valueChanged)
    }
    
    func drawEnviromentSelector(){
        enviromentSelector = UISegmentedControl(items: self.viewModel.enviroments)
        enviromentSelector.selectedSegmentIndex = 0
        enviromentSelector.tintColor = UIColor.black
        enviromentSelector.frame = CGRect(x: frame.minX + 10, y: siteSelector.frame.maxY + 10, width: frame.width - 20, height: frame.height*0.06)
        self.view.addSubview(enviromentSelector)
        enviromentSelector.addTarget(self, action: #selector(changeEnviroment(sender: )), for: .valueChanged)

    }
    
    func drawOnlinePMsSwitchView(){
        let view = UIView()
        view.frame = CGRect(x: frame.minX + 10, y: enviromentSelector.frame.maxY + 10, width: frame.width - 20, height: frame.height*0.06)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        

        let viewFrame = view.bounds
        let onlineSwitch = UISwitch()
        onlineSwitch.setOn(true, animated: false)
        onlineSwitch.frame = CGRect(x: viewFrame.maxX - onlineSwitch.frame.width - 10, y: viewFrame.midY - (onlineSwitch.frame.height/2), width: onlineSwitch.frame.width, height: onlineSwitch.frame.height)
        view.addSubview(onlineSwitch)
        
        let onlineLabel = UILabel()
        onlineLabel.text = "Online Payment Methods"
        onlineLabel.textColor = UIColor.black
        onlineLabel.frame = CGRect(x: viewFrame.minX + 10, y: viewFrame.minY, width: viewFrame.width - onlineSwitch.frame.width - 10, height: viewFrame.height)
        view.addSubview(onlineLabel)
        
        self.view.addSubview(view)
        
    }
    
    func drawOfflinePMsSwitchView(){
        let view = UIView()
        view.frame = CGRect(x: frame.minX + 10, y: enviromentSelector.frame.maxY + 50, width: frame.width - 20, height: frame.height*0.06)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        
        
        let viewFrame = view.bounds
        let onlineSwitch = UISwitch()
        onlineSwitch.setOn(true, animated: false)
        onlineSwitch.frame = CGRect(x: viewFrame.maxX - onlineSwitch.frame.width - 10, y: viewFrame.midY - (onlineSwitch.frame.height/2), width: onlineSwitch.frame.width, height: onlineSwitch.frame.height)
        view.addSubview(onlineSwitch)
        
        let onlineLabel = UILabel()
        onlineLabel.text = "Offline Payment Methods"
        onlineLabel.textColor = UIColor.black
        onlineLabel.frame = CGRect(x: viewFrame.minX + 10, y: viewFrame.minY, width: viewFrame.width - onlineSwitch.frame.width - 10, height: viewFrame.height)
        view.addSubview(onlineLabel)
        
        self.view.addSubview(view)
        
    }
    
    func drawAccountMoneySwitchView(){
        let view = UIView()
        view.frame = CGRect(x: frame.minX + 10, y: frame.minY + 240, width: frame.width - 20, height: frame.height*0.06)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        
        
        let viewFrame = view.bounds
        let onlineSwitch = UISwitch()
        onlineSwitch.setOn(true, animated: false)
        onlineSwitch.frame = CGRect(x: viewFrame.maxX - onlineSwitch.frame.width - 10, y: viewFrame.midY - (onlineSwitch.frame.height/2), width: onlineSwitch.frame.width, height: onlineSwitch.frame.height)
        view.addSubview(onlineSwitch)
        
        let onlineLabel = UILabel()
        onlineLabel.text = "Account Money"
        onlineLabel.textColor = UIColor.black
        onlineLabel.frame = CGRect(x: viewFrame.minX + 10, y: viewFrame.minY, width: viewFrame.width - onlineSwitch.frame.width - 10, height: viewFrame.height)
        view.addSubview(onlineLabel)
        
        self.view.addSubview(view)
        
    }
    
    func drawContinueButton() {
        continueButton.backgroundColor = UIColor.mpDefaultColor()
        continueButton.layer.cornerRadius = 10
        continueButton.titleLabel?.text = "Continue"
        continueButton.titleLabel?.textColor = UIColor.white
    }

    @IBAction func continueAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let NewView = storyboard.instantiateViewController(withIdentifier: "MainTableViewController") as! MainTableViewController
        NewView.prefID = self.viewModel.getPrefID(site: MercadoPagoContext.getSite())
        NewView.title = "Options"
        
        self.navigationController?.pushViewController(NewView, animated: true)
    }
    
    func changeSite(sender: UISegmentedControl) {
        setSite()
    }
    
    func setSite(){
        MercadoPagoContext.setSiteID(self.viewModel.sites[siteSelector.selectedSegmentIndex])
        MercadoPagoContext.setPublicKey(self.viewModel.getPublicKey(site: MercadoPagoContext.getSite(), sandbox: true))
        print(MercadoPagoContext.getSite())
    }
    
    func changeEnviroment(sender: UISegmentedControl) {
        self.viewModel.selectedEnviroment = self.viewModel.enviroments[sender.selectedSegmentIndex]
    }
}
