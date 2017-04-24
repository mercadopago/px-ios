//
//  SettingsViewController.swift
//  PodTester
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/18/17.
//  Copyright © 2017 AUGUSTO COLLERONE ALFONSO. All rights reserved.
//

import UIKit
import MercadoPagoSDK

open class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    
    let viewModel = SettingsViewModel()
    
    override open func viewDidLoad() {
        self.title = "Settings"
        drawContinueButton()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.getHeightFor(indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.viewModel.getCellFor(indexPath: indexPath)
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
        NewView.color = self.viewModel.getColor(site: MercadoPagoContext.getSite())
        NewView.title = "Options"
        
        self.navigationController?.pushViewController(NewView, animated: true)
    }
    
    
//    func setEnviroment(){
//        let sites = self.viewModel.getSites()
//        let site = self.viewModel.getSitefromID(siteID: sites[siteSelector.selectedSegmentIndex].ID)
//        if enviromentSelector.selectedSegmentIndex == 0 {
//            MercadoPagoContext.setPublicKey((site?.pk_sandbox)!)
//            print("Enviroment Changed to Sandbox")
//        } else {
//            MercadoPagoContext.setPublicKey((site?.pk_produ)!)
//            print("Enviroment Changed to Produ")
//        }
//    }
}
