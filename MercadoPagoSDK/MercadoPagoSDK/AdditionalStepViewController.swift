//
//  AdditionalStepViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/13/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class AdditionalStepViewController: MercadoPagoUIScrollViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bundle : Bundle? = MercadoPago.getBundle()
    let viewModel : AdditionalStepViewModel!
    
    
    override open var screenName : String { get { return viewModel.getScreenName()} }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        loadMPStyles()
        
        var upperFrame = UIScreen.main.bounds
        upperFrame.origin.y = -upperFrame.size.height;
        let upperView = UIView(frame: upperFrame)
        upperView.backgroundColor = UIColor.primaryColor()
        tableView.addSubview(upperView)
        
        self.showNavBar()
        loadCells()
    }
    
    func loadCells() {
        let titleNib = UINib(nibName: "AdditionalStepTitleTableViewCell", bundle: self.bundle)
        self.tableView.register(titleNib, forCellReuseIdentifier: "titleNib")
        let cardNib = UINib(nibName: "AdditionalStepCardTableViewCell", bundle: self.bundle)
        self.tableView.register(cardNib, forCellReuseIdentifier: "cardNib")
        let totalRowNib = UINib(nibName: "TotalPayerCostRowTableViewCell", bundle: self.bundle)
        self.tableView.register(totalRowNib, forCellReuseIdentifier: "totalRowNib")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = ""
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
        self.extendedLayoutIncludesOpaqueBars = true
        self.titleCellHeight = 44
    }
    
    override func loadMPStyles(){
        if self.navigationController != nil {
            self.navigationController!.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.navigationBar.tintColor = UIColor(red: 255, green: 255, blue: 255)
            self.navigationController?.navigationBar.barTintColor = UIColor.primaryColor()
            self.navigationController?.navigationBar.removeBottomLine()
            self.navigationController?.navigationBar.isTranslucent = false
            
            displayBackButton()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(viewModel : AdditionalStepViewModel, callback: @escaping ((_ callbackData: NSObject?)-> Void)) {
        self.viewModel = viewModel
        self.viewModel.callback = callback
        super.init(nibName: "AdditionalStepViewController", bundle: self.bundle)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.viewModel.numberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellWidth = self.tableView.bounds.width
        
        if viewModel.isTitleCellFor(indexPath: indexPath) {
            
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleNib", for: indexPath as IndexPath) as! AdditionalStepTitleTableViewCell
            titleCell.selectionStyle = .none
            titleCell.setTitle(string: self.getNavigationBarTitle())
            titleCell.backgroundColor = UIColor.primaryColor()
            self.titleCell = titleCell
            
            return titleCell
            
        } else if viewModel.isCardCellFor(indexPath: indexPath){
            if viewModel.showCardSection(), let cellView = viewModel.getCardSectionView() {
                
                let cardSectionCell = tableView.dequeueReusableCell(withIdentifier: "cardNib", for: indexPath as IndexPath) as! AdditionalStepCardTableViewCell
                cardSectionCell.loadCellView(view: cellView as! UIView)
                cardSectionCell.selectionStyle = .none
                cardSectionCell.updateCardSkin(token: self.viewModel.token, paymentMethod: self.viewModel.paymentMethods[0], view: cellView)
                cardSectionCell.backgroundColor = UIColor.primaryColor()
                
                return cardSectionCell
                
            } else {
                let cardSectionCell = tableView.dequeueReusableCell(withIdentifier: "cardNib", for: indexPath as IndexPath) as! AdditionalStepCardTableViewCell
                cardSectionCell.backgroundColor = UIColor.primaryColor()
                return cardSectionCell
            }
            
        } else if viewModel.isDiscountCellFor(indexPath: indexPath) {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CouponCell")
            cell.contentView.viewWithTag(1)?.removeFromSuperview()
            let discountBody = DiscountBodyCell(frame: CGRect(x: 0, y: 0, width : view.frame.width, height : 84), coupon: self.viewModel.discount, amount:self.viewModel.amount)
            discountBody.tag = 1
            cell.contentView.addSubview(discountBody)
            cell.selectionStyle = .none
            return cell
            
        } else if viewModel.isTotalCellFor(indexPath: indexPath) {
            let cellHeight = Double(viewModel.getAmountDetailCellHeight(indexPath: indexPath))
            let totalCell = tableView.dequeueReusableCell(withIdentifier: "totalRowNib", for: indexPath as IndexPath) as! TotalPayerCostRowTableViewCell
            totalCell.fillCell(total: self.viewModel.amount)
            totalCell.addSeparatorLineToBottom(width: Double(cellWidth), height: cellHeight)
            totalCell.selectionStyle = .none
            return totalCell as UITableViewCell
            
        } else {
            let cell = self.viewModel.dataSource[indexPath.row].getCell(width: Double(cellWidth), height: Double(viewModel.defaultRowCellHeight))
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == AdditionalStepViewModel.Sections.body.rawValue {
            let callbackData: NSObject = self.viewModel.dataSource[indexPath.row] as! NSObject
            self.viewModel.callback!(callbackData)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        self.didScrollInTable(scrollView)
        let visibleIndexPaths = tableView.indexPathsForVisibleRows!
        for index in visibleIndexPaths {
            if index.section == 1  {
                if let card = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? AdditionalStepCardTableViewCell{
                    if tableView.contentOffset.y > 0{
                        if 44/tableView.contentOffset.y < 0.265 && !scrollingDown{
                            card.fadeCard()
                        } else{
                            card.containerView.alpha = 44/tableView.contentOffset.y;
                        }
                    }
                }
            }
        }
        
    }
    
    override func getNavigationBarTitle() -> String {
        return self.viewModel.getTitle()
    }
    
}
