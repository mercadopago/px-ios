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
        self.viewModel.update()
        NewView.prefID = self.viewModel.selectedSite.getPrefID()
        NewView.color = self.viewModel.selectedColor
        NewView.title = "Options"
        
        self.navigationController?.pushViewController(NewView, animated: true)
    }
}
